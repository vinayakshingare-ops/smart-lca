require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { google } = require('googleapis');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Load Service Account from env or file
// Use a service account key with Earth Engine API enabled
const serviceAccountKey = process.env.GOOGLE_APPLICATION_CREDENTIALS || './serviceAccountKey.json';

// Initialize Earth Engine API client auth
let eeAuthToken = null;

async function getEarthEngineToken() {
  try {
    const auth = new google.auth.GoogleAuth({
      keyFile: serviceAccountKey,
      scopes: ['https://www.googleapis.com/auth/earthengine'],
    });
    const client = await auth.getClient();
    const token = await client.getAccessToken();
    eeAuthToken = token.token;
    console.log("Acquired fresh Earth Engine auth token");
  } catch (error) {
    console.error("Failed to authenticate Earth Engine. Using mock data for client fallback.", error.message);
  }
}

// Fetch token on startup
getEarthEngineToken();

// Refresh token every 45 minutes
setInterval(getEarthEngineToken, 45 * 60 * 1000);

// Endpoint for the Flutter app to fetch the securely signed temporary token
// OR proxy map ID creation requests.
app.get('/api/gee/token', (req, res) => {
  if (eeAuthToken) {
    res.json({ success: true, token: eeAuthToken });
  } else {
    // If not configured, send a mock response so the frontend can fallback gracefully
    res.json({ success: false, error: 'Earth Engine credentials not configured on backend. Returning mock.' });
  }
});

// Mock Endpoint to simulate a GEE MapID response for Sentinel-2 NDVI
app.get('/api/gee/mapid', (req, res) => {
  const lat = req.query.lat || 18.52;
  const lng = req.query.lng || 73.85;

  // In a real app, this would use the `@google/earthengine` Node package to evaluate a script:
  // e.g. ee.ImageCollection("COPERNICUS/S2_SR").filterBounds(ee.Geometry.Point(lng, lat))...
  // and then return the mapid and token.
  
  res.json({
    mapid: 'mock_map_id_12345',
    token: 'mock_token_abcde',
    urlFormat: `https://earthengine.googleapis.com/v1alpha/projects/earthengine-legacy/maps/mock_map_id_12345-mock_token_abcde/tiles/{z}/{x}/{y}`,
    alerts: ["Deforestation +15% detected in the selected timeframe."]
  });
});

app.listen(PORT, () => {
  console.log(`Earth Engine Proxy Server running on port ${PORT}`);
  console.log('Provide a valid serviceAccountKey.json to fully enable the Earth Engine API connection.');
});
