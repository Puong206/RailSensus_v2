const fs = require('fs');
const path = require('path');

exports.deleteFileSafe = (fileUrl) => {
  if (!fileUrl) return;
  try {
    // Determine the absolute path of the file
    // fileUrl usually looks like "/uploads/filename.jpg"
    const filename = fileUrl.replace('/uploads/', '');
    const absolutePath = path.join(__dirname, '../../uploads', filename);

    if (fs.existsSync(absolutePath)) {
      fs.unlinkSync(absolutePath);
    }
  } catch (error) {
    console.error(`Failed to delete file: ${fileUrl}`, error.message);
  }
};
