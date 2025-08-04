-- AI-NOC Database Initialization
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Devices table
CREATE TABLE IF NOT EXISTS devices (
    device_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ip_address INET NOT NULL UNIQUE,
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    snmp_community VARCHAR(50) DEFAULT 'public',
    snmp_port INTEGER DEFAULT 161,
    status VARCHAR(20) DEFAULT 'unknown',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample devices
INSERT INTO devices (ip_address, device_name, device_type, location) VALUES
('192.168.1.1', 'Core Router', 'router', 'Data Center'),
('192.168.1.10', 'Access Switch 1', 'switch', 'Floor 3'),
('192.168.1.2', 'Firewall', 'firewall', 'DMZ'),
('192.168.1.100', 'Web Server', 'server', 'Data Center')
ON CONFLICT (ip_address) DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO noc_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO noc_user;
