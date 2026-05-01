const axios = require('axios');

// Calculate distance in km between two coordinates
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

exports.getLocationFromCoordinates = async (latitude, longitude) => {
  try {
    const radius = 10000; // 10km radius to find stations
    const query = `
      [out:json];
      (
        node["railway"="station"](around:${radius},${latitude},${longitude});
        way["railway"="station"](around:${radius},${latitude},${longitude});
        relation["railway"="station"](around:${radius},${latitude},${longitude});
      );
      out center;
    `;

    const overpassResponse = await axios.get('https://overpass-api.de/api/interpreter', {
      params: { data: query },
      headers: {
        'User-Agent': 'RailSensusBackend/1.0 (admin@railsensus.com)'
      },
      timeout: 8000
    });

    const elements = overpassResponse.data.elements;
    if (elements && elements.length > 0) {
      let nearestStation = null;
      let minDistance = Infinity;

      for (const el of elements) {
        const elLat = el.lat || (el.center && el.center.lat);
        const elLon = el.lon || (el.center && el.center.lon);
        const name = el.tags && (el.tags.name || el.tags.alt_name);

        if (elLat && elLon && name) {
          const dist = getDistanceFromLatLonInKm(latitude, longitude, elLat, elLon);
          if (dist < minDistance) {
            minDistance = dist;
            nearestStation = name;
          }
        }
      }

      if (nearestStation) {
        const formattedDist = minDistance.toFixed(1);
        return `Stasiun ${nearestStation.replace(/stasiun/i, '').trim()} (${formattedDist} km)`;
      }
    }

    // Fallback to Nominatim if no station found
    const response = await axios.get('https://nominatim.openstreetmap.org/reverse', {
      params: {
        format: 'json',
        lat: latitude,
        lon: longitude,
        zoom: 18,
        addressdetails: 1
      },
      headers: {
        'User-Agent': 'RailSensusBackend/1.0 (admin@railsensus.com)'
      },
      timeout: 5000
    });

    if (response.data && response.data.display_name) {
      return response.data.display_name;
    }
    return "Lokasi Tidak Diketahui";
  } catch (error) {
    console.error('OSM API Error:', error.message);
    return "Lokasi Tidak Diketahui";
  }
};
