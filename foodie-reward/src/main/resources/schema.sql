CREATE TABLE IF NOT EXISTS memberships (
    mem_id VARCHAR(5) PRIMARY KEY,
    tier_id VARCHAR(3) NOT NULL,
    join_date VARCHAR(10) NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('Active', 'Inactive'))
);

CREATE TABLE IF NOT EXISTS customers (
    cust_id INT PRIMARY KEY,
    cust_name VARCHAR(80) NOT NULL,
    phone_num VARCHAR(20) NOT NULL,
    cust_email VARCHAR(100) NOT NULL UNIQUE,
    mem_id VARCHAR(5) NOT NULL REFERENCES memberships(mem_id),
    total_paid DECIMAL(10,2) DEFAULT 0 NOT NULL,
    transaction_count INT DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS point_accounts (
    cust_id INT PRIMARY KEY REFERENCES customers(cust_id),
    mem_id VARCHAR(5) NOT NULL REFERENCES memberships(mem_id),
    points_balance INT DEFAULT 0 NOT NULL,
    point_status VARCHAR(20) NOT NULL CHECK (point_status IN ('Active', 'Expiry')),
    total_points_earned INT DEFAULT 0 NOT NULL,
    total_points_used INT DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS reward_catalogs (
    catalog_id VARCHAR(5) PRIMARY KEY,
    catalog_name VARCHAR(80) NOT NULL,
    catalog_description VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS rewards (
    reward_id VARCHAR(5) PRIMARY KEY,
    reward_name VARCHAR(100) NOT NULL,
    points_required INT NOT NULL CHECK (points_required > 0),
    reward_type VARCHAR(30) NOT NULL,
    stock INT DEFAULT 0 NOT NULL CHECK (stock >= 0),
    catalog_id VARCHAR(5) NOT NULL REFERENCES reward_catalogs(catalog_id),
    last_restock VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS reward_transactions (
    transaction_id VARCHAR(5) PRIMARY KEY,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('Earn', 'Redeem')),
    points_earned INT DEFAULT 0 NOT NULL,
    points_redeemed INT DEFAULT 0 NOT NULL,
    transaction_date VARCHAR(10) NOT NULL,
    transaction_status VARCHAR(10) NOT NULL CHECK (transaction_status IN ('Completed', 'Pending', 'Failed')),
    cust_id INT NOT NULL REFERENCES customers(cust_id)
);

CREATE TABLE IF NOT EXISTS redemptions (
    redemption_id VARCHAR(5) PRIMARY KEY,
    cust_id INT NOT NULL REFERENCES customers(cust_id),
    reward_id VARCHAR(5) NOT NULL REFERENCES rewards(reward_id),
    redemption_date VARCHAR(10) NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('Pending', 'Completed', 'Failed')),
    transaction_id VARCHAR(5),
    points_used INT DEFAULT 0 NOT NULL
);
