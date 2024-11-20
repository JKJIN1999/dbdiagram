-- users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- Nullable for third-party accounts
    user_type VARCHAR(50) CHECK (user_type IN ('individual', 'institute')) NOT NULL,
    profile_picture TEXT,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_longitude DECIMAL(7,4),
    last_latitude DECIMAL(7,4),
    is_active BOOLEAN DEFAULT TRUE,
    auth_method VARCHAR(50) CHECK (auth_method IN ('password', 'google', 'facebook', 'apple')) NOT NULL
);

CREATE TABLE UserAuthProviders (
    provider_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    provider_name VARCHAR(50) NOT NULL, -- e.g., 'google', 'facebook', 'apple'
    provider_user_id VARCHAR(255) NOT NULL, -- Third-party unique identifier
    access_token TEXT, -- Optional, if you want to store the token
    refresh_token TEXT, -- Optional, for OAuth flows
    expires_at TIMESTAMP, -- Optional, for token expiration
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- communities table
CREATE TABLE Communities (
    community_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- community membership table
CREATE TABLE CommunityMembership (
    membership_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    community_id INT REFERENCES Communities(community_id),
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- posts table
CREATE TABLE Posts (
    post_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    community_id INT REFERENCES Communities(community_id),
    content TEXT,
    image_url TEXT[],
    video_url TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    flagged BOOLEAN DEFAULT FALSE
);

-- comments table
CREATE TABLE Comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES Posts(post_id),
    user_id INT REFERENCES Users(user_id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    visible BOOLEAN DEFAULT TRUE
);

-- likes table
CREATE TABLE Likes (
    post_id INT REFERENCES Posts(post_id),
    user_id INT REFERENCES Users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (post_id, user_id) 
);

-- friends table
CREATE TABLE Followings (
    follower INT REFERENCES Users(user_id),
    followee INT REFERENCES Users(user_id),
    status VARCHAR(50) CHECK (status IN ('pending', 'accepted')) NOT NULL,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (follower, followee)
);

-- chat messages table
CREATE TABLE ChatMessages (
    message_id SERIAL PRIMARY KEY,
    sender_id INT REFERENCES Users(user_id),
    receiver_id INT REFERENCES Users(user_id),
    message_content TEXT, -- For plain text messages
    file_url TEXT, -- Stores the URL or path to the attached file
    file_type VARCHAR(50), -- Stores the type of the file (e.g., 'image', 'video', 'document')
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- competitions table
CREATE TABLE Competitions (
    competition_id SERIAL PRIMARY KEY,
    community_id INT REFERENCES Communities(community_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- competition rankings table
CREATE TABLE CompetitionRankings (
    ranking_id SERIAL PRIMARY KEY,
    competition_id INT REFERENCES Competitions(competition_id),
    user_id INT REFERENCES Users(user_id),
    rank INT NOT NULL,
    score DECIMAL(10, 2) NOT NULL
);
