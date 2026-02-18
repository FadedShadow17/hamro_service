import express from 'express';
import cors from 'cors';
import os from 'os';

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'hamro-service-backend' });
});

function getLocalIpAddress(): string {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    const nets = interfaces[name];
    if (nets) {
      for (const net of nets) {
        if (net.family === 'IPv4' && !net.internal) {
          return net.address;
        }
      }
    }
  }
  return 'localhost';
}

app.listen(PORT, '0.0.0.0', () => {
  const localIp = getLocalIpAddress();
  console.log(`Server running on port ${PORT}`);
  console.log(`Local: http://localhost:${PORT}`);
  console.log(`LAN: http://${localIp}:${PORT}`);
  console.log(`\n⚠️  FIREWALL SETUP REQUIRED:`);
  console.log(`   Please allow port ${PORT} in your firewall settings`);
  console.log(`   Windows: Allow port ${PORT} through Windows Defender Firewall`);
  console.log(`   Mac/Linux: Configure firewall to allow TCP port ${PORT}\n`);
});
