CREATE DATABASE IF NOT EXISTS dcs_arena;
USE dcs_arena;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'captain', 'admin') NOT NULL DEFAULT 'student',
    is_verified TINYINT(1) NOT NULL DEFAULT 0,
    verification_token VARCHAR(255) NULL,
    privacy_consent TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    student_number VARCHAR(50) NULL,
    full_name VARCHAR(255) NOT NULL,
    year_level VARCHAR(50) NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS captains (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    approved_by_admin_id INT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by_admin_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    capacity INT NOT NULL DEFAULT 0,
    registration_deadline DATETIME NULL,
    bracket_type ENUM('single_elimination', 'double_elimination', 'round_robin') NOT NULL DEFAULT 'single_elimination',
    created_by_admin_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_admin_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sport_id INT NOT NULL,
    captain_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    max_members INT NOT NULL DEFAULT 12,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_team_name_per_sport (sport_id, name),
    FOREIGN KEY (sport_id) REFERENCES sports(id) ON DELETE CASCADE,
    FOREIGN KEY (captain_id) REFERENCES captains(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    team_id INT NOT NULL,
    sport_id INT NOT NULL,
    status ENUM('registered', 'waitlisted', 'cancelled') NOT NULL DEFAULT 'registered',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_student_team_sport (student_id, team_id, sport_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS venues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    location VARCHAR(255) NULL,
    capacity INT NULL
);

CREATE TABLE IF NOT EXISTS matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sport_id INT NOT NULL,
    team_a_id INT NOT NULL,
    team_b_id INT NOT NULL,
    venue_id INT NULL,
    scheduled_at DATETIME NOT NULL,
    score_a INT NULL,
    score_b INT NULL,
    winner_team_id INT NULL,
    bracket_round VARCHAR(100) NULL,
    bracket_payload JSON NULL,
    status ENUM('upcoming', 'ongoing', 'completed', 'cancelled') NOT NULL DEFAULT 'upcoming',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sport_id) REFERENCES sports(id) ON DELETE CASCADE,
    FOREIGN KEY (team_a_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (team_b_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES venues(id) ON DELETE SET NULL,
    FOREIGN KEY (winner_team_id) REFERENCES teams(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    body TEXT NOT NULL,
    priority ENUM('low', 'normal', 'high') NOT NULL DEFAULT 'normal',
    pinned TINYINT(1) NOT NULL DEFAULT 0,
    created_by_admin_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_admin_id) REFERENCES admins(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    sport_id INT NOT NULL,
    qr_token VARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    checked_in_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_student_sport_attendance (student_id, sport_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS recruitment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL,
    sport_id INT NOT NULL,
    captain_id INT NOT NULL,
    title VARCHAR(180) NOT NULL,
    position_needed VARCHAR(120) NULL,
    requirements TEXT NULL,
    slots_available INT NOT NULL DEFAULT 1,
    applicant_student_id INT NULL,
    application_status ENUM('open', 'applied', 'accepted', 'rejected') NOT NULL DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(id) ON DELETE CASCADE,
    FOREIGN KEY (captain_id) REFERENCES captains(id) ON DELETE CASCADE,
    FOREIGN KEY (applicant_student_id) REFERENCES students(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS leaderboard (
    team_id INT NOT NULL,
    sport_id INT NOT NULL,
    wins INT NOT NULL DEFAULT 0,
    losses INT NOT NULL DEFAULT 0,
    draws INT NOT NULL DEFAULT 0,
    points INT NOT NULL DEFAULT 0,
    gold INT NOT NULL DEFAULT 0,
    silver INT NOT NULL DEFAULT 0,
    bronze INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (team_id, sport_id),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(id) ON DELETE CASCADE
);

CREATE INDEX idx_registrations_sport_status ON registrations (sport_id, status);
CREATE INDEX idx_matches_sport_status ON matches (sport_id, status);
CREATE INDEX idx_announcements_priority_pinned ON announcements (priority, pinned);
