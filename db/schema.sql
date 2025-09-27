-- Core schema
DROP TABLE IF EXISTS favourites; DROP TABLE IF EXISTS ratings; DROP TABLE IF EXISTS recipe_steps;
DROP TABLE IF EXISTS recipe_ingredients; DROP TABLE IF EXISTS ingredients; DROP TABLE IF EXISTS recipe_categories; DROP TABLE IF EXISTS recipe_dietary_attributes; DROP TABLE IF EXISTS dietary_attributes;
DROP TABLE IF EXISTS categories; DROP TABLE IF EXISTS recipes; DROP TABLE IF EXISTS users;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE recipes (id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(200) NOT NULL, summary TEXT, difficulty ENUM('Easy','Medium','Hard') DEFAULT 'Easy', image_url VARCHAR(255) NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE categories (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE recipe_categories (recipe_id INT NOT NULL, category_id INT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (recipe_id, category_id), FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE, FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE dietary_attributes (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    name VARCHAR(100) NOT NULL UNIQUE, 
    description TEXT, 
    display_order INT DEFAULT 0,
    category ENUM('diet', 'allergen', 'lifestyle', 'nutrition') DEFAULT 'diet',
    severity ENUM('preference', 'restriction', 'allergy') DEFAULT 'preference',
    is_exclusion BOOLEAN DEFAULT FALSE,
    icon VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Same join table, but potentially with confidence levels
CREATE TABLE recipe_dietary_attributes (
    recipe_id INT NOT NULL, 
    dietary_attribute_id INT NOT NULL, 
    confidence ENUM('verified', 'likely', 'possible') DEFAULT 'verified',
    notes TEXT NULL,
    verified_by INT NULL,
    verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (recipe_id, dietary_attribute_id), 
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE, 
    FOREIGN KEY (dietary_attribute_id) REFERENCES dietary_attributes(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE ingredients (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ingredient taxonomy/synonyms for better searching and allergen mapping
CREATE TABLE ingredient_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    parent_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES ingredient_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ingredient_category_map (
    ingredient_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (ingredient_id, category_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES ingredient_categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ingredient_synonyms (
    ingredient_id INT NOT NULL,
    synonym VARCHAR(120) NOT NULL,
    PRIMARY KEY (ingredient_id, synonym),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: link ingredients to allergen dietary_attributes for precise allergen exclusion
CREATE TABLE ingredient_allergens (
    ingredient_id INT NOT NULL,
    dietary_attribute_id INT NOT NULL,
    PRIMARY KEY (ingredient_id, dietary_attribute_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
    FOREIGN KEY (dietary_attribute_id) REFERENCES dietary_attributes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recipe_ingredients (
    recipe_id INT NOT NULL,
    ingredient_id INT NOT NULL, 
    quantity DECIMAL(8,3) NULL,
    unit VARCHAR(50) NULL,
    quantity_text VARCHAR(100) NULL,
    preparation VARCHAR(150) NULL,
    ingredient_group VARCHAR(100) DEFAULT 'Main',
    is_optional BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    notes TEXT NULL,
    substitutions TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (recipe_id, ingredient_id), 
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE, 
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE recipe_steps (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    recipe_id INT NOT NULL, 
    step_no INT NOT NULL, 
    instruction TEXT NOT NULL, 
    minutes INT NOT NULL DEFAULT 5,
    step_group INT DEFAULT 1,
    is_parallel BOOLEAN DEFAULT FALSE,
    parallel_parent_step INT NULL,
    step_type ENUM('prep', 'cook', 'combine', 'wait', 'serve') DEFAULT 'cook',
    temperature VARCHAR(50) NULL,
    equipment VARCHAR(100) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (parallel_parent_step) REFERENCES recipe_steps(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE ratings (user_id INT NOT NULL, recipe_id INT NOT NULL, overall TINYINT NOT NULL CHECK (overall BETWEEN 1 AND 5), taste TINYINT NULL CHECK (taste BETWEEN 0 AND 5), aesthetics TINYINT NULL CHECK (aesthetics BETWEEN 0 AND 5), difficulty_score TINYINT NULL CHECK (difficulty_score BETWEEN 0 AND 5), updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (user_id, recipe_id), FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE favourites (user_id INT NOT NULL, recipe_id INT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (user_id, recipe_id), FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- extras_2 schema bits
CREATE TABLE IF NOT EXISTS tags (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS recipe_tags (recipe_id INT NOT NULL, tag_id INT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (recipe_id, tag_id), FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE, FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nutrition (recipe_id INT NOT NULL PRIMARY KEY, calories_kcal INT NOT NULL, protein_g DECIMAL(6,2) NOT NULL, carbs_g DECIMAL(6,2) NOT NULL, fat_g DECIMAL(6,2) NOT NULL, FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE INDEX idx_recipe_title ON recipes(title);
CREATE INDEX idx_ing_name ON ingredients(name);
CREATE INDEX idx_step_recipe ON recipe_steps(recipe_id);
CREATE INDEX idx_step_group ON recipe_steps(recipe_id, step_group, step_no);
CREATE INDEX idx_ingredient_group ON recipe_ingredients(recipe_id, ingredient_group, display_order);
CREATE INDEX idx_dietary_attr_order ON dietary_attributes(display_order);

-- Performance/completeness: composite indexes for common filters/joins
CREATE INDEX idx_recipe_categories_cat_recipe ON recipe_categories(category_id, recipe_id);
CREATE INDEX idx_recipe_tags_tag_recipe ON recipe_tags(tag_id, recipe_id);
CREATE INDEX idx_recipe_dietary_attr ON recipe_dietary_attributes(dietary_attribute_id, recipe_id, confidence);
CREATE INDEX idx_recipe_ingredients_ing_recipe ON recipe_ingredients(ingredient_id, recipe_id);

-- Better keyword search
FULLTEXT INDEX ft_recipes_title_summary ON recipes(title, summary);

-- Ingredient discovery helpers
CREATE INDEX idx_ing_synonym ON ingredient_synonyms(synonym);
CREATE INDEX idx_ingcat_map ON ingredient_category_map(category_id, ingredient_id);

-- Realistic timing: sum of max minutes per step_group
CREATE OR REPLACE VIEW recipe_timing AS
SELECT 
  recipe_id,
  SUM(group_max_minutes) AS total_minutes
FROM (
  SELECT recipe_id, step_group, MAX(minutes) AS group_max_minutes
  FROM recipe_steps
  GROUP BY recipe_id, step_group
) t
GROUP BY recipe_id;
