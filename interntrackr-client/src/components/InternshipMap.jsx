import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix for default map marker icons not showing in React
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

export default function InternshipMap({ applications }) {
  // Default center of the map (Manila, Philippines)
  const defaultCenter = [14.5995, 120.9842]; 

  return (
    <div style={{ width: '100%', height: '400px', borderRadius: '12px', overflow: 'hidden', border: '1px solid var(--border)', zIndex: 0, position: 'relative' }}>
      <MapContainer center={defaultCenter} zoom={3} style={{ height: '100%', width: '100%' }}>
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; OpenStreetMap contributors'
        />
        
        {applications && applications.map((app) => {
          if (app.lat && app.lng) {
            return (
              /* Fixed: changed app._id to app.id for Firebase */
              <Marker key={app.id} position={[app.lat, app.lng]}>
                <Popup>
                  <strong style={{ color: '#000' }}>{app.company}</strong><br />
                  <span style={{ color: '#333' }}>{app.role}</span><br />
                  <span style={{ fontSize: '0.8rem', color: '#666' }}>{app.location}</span>
                </Popup>
              </Marker>
            );
          }
          return null;
        })}
      </MapContainer>
    </div>
  );
}