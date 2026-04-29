CREATE TABLE regulations (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    fine_amount DOUBLE PRECISION,
    status VARCHAR(50),
    created_at TIMESTAMP
);