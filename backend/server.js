require('dotenv').config();
const app = require('./app');
const initCronJobs = require('./src/utils/cronJobs');

const PORT = process.env.PORT || 3000;

// Initialize background cron jobs
initCronJobs();

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
