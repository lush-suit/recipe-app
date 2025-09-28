-- seed_all.sql (complete with dietary_attributes, ingredient taxonomy, synonyms, and allergens)
-- This file includes all seed data with enhanced ingredient categorization and search features.

-- Categories (focused on meal types and course classification)
INSERT IGNORE INTO categories(name) VALUES ('Starter'),('Main'),('Dessert'),('Quick'),('Budget');

-- Enhanced Dietary Attributes with categorization
INSERT IGNORE INTO dietary_attributes(name, description, display_order, category, severity, is_exclusion, icon) VALUES
-- Dietary Preferences
('Vegetarian', 'Contains no meat, fish, or poultry', 10, 'diet', 'preference', TRUE, '🌱'),
('Vegan', 'Contains no animal products including dairy and eggs', 20, 'diet', 'restriction', TRUE, '🌿'),
('Pescatarian', 'Vegetarian diet that includes fish and seafood', 30, 'diet', 'preference', FALSE, '🐟'),
('Paleo', 'Follows paleo diet principles - no grains, legumes, dairy', 40, 'lifestyle', 'preference', TRUE, '🥩'),
('Keto-Friendly', 'Very low carb (under 20g), high fat', 50, 'nutrition', 'restriction', FALSE, '🥑'),
('Low-Carb', 'Lower in carbohydrates (under 30g per serving)', 60, 'nutrition', 'preference', FALSE, '📉'),
('High-Protein', 'High in protein (over 25g per serving)', 70, 'nutrition', 'preference', FALSE, '💪'),

-- Allergens (Critical - these are safety issues)
('Gluten-Free', 'Contains no wheat, barley, rye, or gluten ingredients', 100, 'allergen', 'allergy', TRUE, '🌾'),
('Dairy-Free', 'Contains no milk, cheese, butter, or dairy products', 110, 'allergen', 'allergy', TRUE, '🥛'),
('Egg-Free', 'Contains no eggs or egg-derived ingredients', 120, 'allergen', 'allergy', TRUE, '🥚'),
('Nut-Free', 'Contains no tree nuts (almonds, walnuts, etc.)', 130, 'allergen', 'allergy', TRUE, '🥜'),
('Peanut-Free', 'Contains no peanuts or peanut-derived products', 140, 'allergen', 'allergy', TRUE, '🥜'),
('Shellfish-Free', 'Contains no shellfish (shrimp, crab, lobster, etc.)', 150, 'allergen', 'allergy', TRUE, '🦐'),
('Fish-Free', 'Contains no fish or fish-derived ingredients', 160, 'allergen', 'allergy', TRUE, '🐟'),
('Soy-Free', 'Contains no soybeans or soy-derived products', 170, 'allergen', 'allergy', TRUE, '🫘'),
('Sesame-Free', 'Contains no sesame seeds or sesame oil', 180, 'allergen', 'allergy', TRUE, '🌰'),

-- Lifestyle/Religious
('Halal', 'Prepared according to Islamic dietary laws', 200, 'lifestyle', 'restriction', FALSE, '☪️'),
('Kosher', 'Prepared according to Jewish dietary laws', 210, 'lifestyle', 'restriction', FALSE, '✡️'),
('Raw Food', 'Not heated above 118°F (48°C)', 220, 'lifestyle', 'preference', FALSE, '🥗');

-- Demo user (Password123! hash)
INSERT IGNORE INTO users(name,email,password_hash) VALUES ('Demo User','demo@example.com','$2y$10$Kp7T8r7j4xQ0Q9d2Z2g8W.zvZ3C2l2Vq1o6a3xM1r6R9y2b1QmJk2');

-- Ingredients
INSERT IGNORE INTO ingredients(name) VALUES
                                         ('Spaghetti'),('Minced beef'),('Tomato sauce'),('Onion'),('Garlic'),('Olive oil'),('Dried oregano'),('Salt'),('Black pepper'),
                                         ('Plain flour'),('Plant milk'),('Baking powder'),('Maple syrup'),
                                         ('Wholemeal base'),('Mozzarella'),('Bell pepper'),('Mushroom'),
                                         ('Basmati rice'),('Lamb'),('Curry powder'),('Yogurt'),
                                         ('Couscous'),('Chickpeas'),('Cucumber'),('Lemon'),
                                         ('Plums'),('Eggs'),('Sugar'),('Butter'),
                                         ('Mango'),('Pie crust'),('Lime'),('Cornflour'),('Coconut cream'),('Vanilla'),
                                         ('Flatbread'),('Paprika'),('Ground cumin'),('Tahini'),('Lettuce'),('Tomato'),
                                         ('Tomatoes'),('Vegetable stock'),('Basil'),('Cream'),
                                         ('Chicken breast'),('Mixed salad leaves'),('Olives'),('Feta'),('Balsamic vinegar');

-- Ingredient Categories (hierarchical taxonomy)
INSERT IGNORE INTO ingredient_categories (name, parent_id) VALUES
-- Top-level categories
('Grains & Cereals', NULL),
('Proteins', NULL),
('Dairy & Alternatives', NULL),
('Vegetables', NULL),
('Fruits', NULL),
('Herbs & Spices', NULL),
('Fats & Oils', NULL),
('Condiments & Sauces', NULL),
('Baking', NULL),
('Nuts & Seeds', NULL);

-- Phase 2: Insert sub-categories via SELECT (parents now exist)
-- Under Grains & Cereals
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Pasta', id FROM ingredient_categories WHERE name='Grains & Cereals';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Rice', id FROM ingredient_categories WHERE name='Grains & Cereals';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Flour & Baking Bases', id FROM ingredient_categories WHERE name='Grains & Cereals';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Bread & Wraps', id FROM ingredient_categories WHERE name='Grains & Cereals';

-- Sub-categories under Proteins
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Meat', id FROM ingredient_categories WHERE name='Proteins';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Poultry', id FROM ingredient_categories WHERE name='Proteins';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Legumes', id FROM ingredient_categories WHERE name='Proteins';

-- Sub-categories under Vegetables
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Alliums', id FROM ingredient_categories WHERE name='Vegetables';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Leafy Greens', id FROM ingredient_categories WHERE name='Vegetables';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Nightshades', id FROM ingredient_categories WHERE name='Vegetables';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Mushrooms', id FROM ingredient_categories WHERE name='Vegetables';

-- Sub-categories under Fruits
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Stone Fruits', id FROM ingredient_categories WHERE name='Fruits';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Tropical Fruits', id FROM ingredient_categories WHERE name='Fruits';
INSERT IGNORE INTO ingredient_categories (name, parent_id) SELECT 'Citrus', id FROM ingredient_categories WHERE name='Fruits';

-- Map ingredients to categories
INSERT IGNORE INTO ingredient_category_map (ingredient_id, category_id) VALUES
-- Pasta
((SELECT id FROM ingredients WHERE name='Spaghetti'), (SELECT id FROM ingredient_categories WHERE name='Pasta')),

-- Meat
((SELECT id FROM ingredients WHERE name='Minced beef'), (SELECT id FROM ingredient_categories WHERE name='Meat')),
((SELECT id FROM ingredients WHERE name='Lamb'), (SELECT id FROM ingredient_categories WHERE name='Meat')),

-- Poultry
((SELECT id FROM ingredients WHERE name='Chicken breast'), (SELECT id FROM ingredient_categories WHERE name='Poultry')),

-- Dairy
((SELECT id FROM ingredients WHERE name='Mozzarella'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),
((SELECT id FROM ingredients WHERE name='Yogurt'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),
((SELECT id FROM ingredients WHERE name='Butter'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),
((SELECT id FROM ingredients WHERE name='Cream'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),
((SELECT id FROM ingredients WHERE name='Feta'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),
((SELECT id FROM ingredients WHERE name='Plant milk'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),
((SELECT id FROM ingredients WHERE name='Coconut cream'), (SELECT id FROM ingredient_categories WHERE name='Dairy & Alternatives')),

-- Alliums
((SELECT id FROM ingredients WHERE name='Onion'), (SELECT id FROM ingredient_categories WHERE name='Alliums')),
((SELECT id FROM ingredients WHERE name='Garlic'), (SELECT id FROM ingredient_categories WHERE name='Alliums')),

-- Nightshades
((SELECT id FROM ingredients WHERE name='Tomato sauce'), (SELECT id FROM ingredient_categories WHERE name='Nightshades')),
((SELECT id FROM ingredients WHERE name='Tomatoes'), (SELECT id FROM ingredient_categories WHERE name='Nightshades')),
((SELECT id FROM ingredients WHERE name='Tomato'), (SELECT id FROM ingredient_categories WHERE name='Nightshades')),
((SELECT id FROM ingredients WHERE name='Bell pepper'), (SELECT id FROM ingredient_categories WHERE name='Nightshades')),

-- Leafy Greens
((SELECT id FROM ingredients WHERE name='Lettuce'), (SELECT id FROM ingredient_categories WHERE name='Leafy Greens')),
((SELECT id FROM ingredients WHERE name='Mixed salad leaves'), (SELECT id FROM ingredient_categories WHERE name='Leafy Greens')),
((SELECT id FROM ingredients WHERE name='Basil'), (SELECT id FROM ingredient_categories WHERE name='Leafy Greens')),

-- Mushrooms
((SELECT id FROM ingredients WHERE name='Mushroom'), (SELECT id FROM ingredient_categories WHERE name='Mushrooms')),

-- Other vegetables
((SELECT id FROM ingredients WHERE name='Cucumber'), (SELECT id FROM ingredient_categories WHERE name='Vegetables')),

-- Rice
((SELECT id FROM ingredients WHERE name='Basmati rice'), (SELECT id FROM ingredient_categories WHERE name='Rice')),
((SELECT id FROM ingredients WHERE name='Couscous'), (SELECT id FROM ingredient_categories WHERE name='Grains & Cereals')),

-- Legumes
((SELECT id FROM ingredients WHERE name='Chickpeas'), (SELECT id FROM ingredient_categories WHERE name='Legumes')),

-- Stone Fruits
((SELECT id FROM ingredients WHERE name='Plums'), (SELECT id FROM ingredient_categories WHERE name='Stone Fruits')),

-- Tropical Fruits
((SELECT id FROM ingredients WHERE name='Mango'), (SELECT id FROM ingredient_categories WHERE name='Tropical Fruits')),

-- Citrus
((SELECT id FROM ingredients WHERE name='Lemon'), (SELECT id FROM ingredient_categories WHERE name='Citrus')),
((SELECT id FROM ingredients WHERE name='Lime'), (SELECT id FROM ingredient_categories WHERE name='Citrus')),

-- Flour & Baking
((SELECT id FROM ingredients WHERE name='Plain flour'), (SELECT id FROM ingredient_categories WHERE name='Flour & Baking Bases')),
((SELECT id FROM ingredients WHERE name='Wholemeal base'), (SELECT id FROM ingredient_categories WHERE name='Flour & Baking Bases')),
((SELECT id FROM ingredients WHERE name='Pie crust'), (SELECT id FROM ingredient_categories WHERE name='Flour & Baking Bases')),

-- Bread & Wraps
((SELECT id FROM ingredients WHERE name='Flatbread'), (SELECT id FROM ingredient_categories WHERE name='Bread & Wraps')),

-- Baking
((SELECT id FROM ingredients WHERE name='Baking powder'), (SELECT id FROM ingredient_categories WHERE name='Baking')),
((SELECT id FROM ingredients WHERE name='Sugar'), (SELECT id FROM ingredient_categories WHERE name='Baking')),
((SELECT id FROM ingredients WHERE name='Vanilla'), (SELECT id FROM ingredient_categories WHERE name='Baking')),
((SELECT id FROM ingredients WHERE name='Cornflour'), (SELECT id FROM ingredient_categories WHERE name='Baking')),
((SELECT id FROM ingredients WHERE name='Eggs'), (SELECT id FROM ingredient_categories WHERE name='Baking')),

-- Herbs & Spices
((SELECT id FROM ingredients WHERE name='Dried oregano'), (SELECT id FROM ingredient_categories WHERE name='Herbs & Spices')),
((SELECT id FROM ingredients WHERE name='Curry powder'), (SELECT id FROM ingredient_categories WHERE name='Herbs & Spices')),
((SELECT id FROM ingredients WHERE name='Paprika'), (SELECT id FROM ingredient_categories WHERE name='Herbs & Spices')),
((SELECT id FROM ingredients WHERE name='Ground cumin'), (SELECT id FROM ingredient_categories WHERE name='Herbs & Spices')),
((SELECT id FROM ingredients WHERE name='Salt'), (SELECT id FROM ingredient_categories WHERE name='Herbs & Spices')),
((SELECT id FROM ingredients WHERE name='Black pepper'), (SELECT id FROM ingredient_categories WHERE name='Herbs & Spices')),

-- Fats & Oils
((SELECT id FROM ingredients WHERE name='Olive oil'), (SELECT id FROM ingredient_categories WHERE name='Fats & Oils')),

-- Condiments & Sauces
((SELECT id FROM ingredients WHERE name='Maple syrup'), (SELECT id FROM ingredient_categories WHERE name='Condiments & Sauces')),
((SELECT id FROM ingredients WHERE name='Tahini'), (SELECT id FROM ingredient_categories WHERE name='Condiments & Sauces')),
((SELECT id FROM ingredients WHERE name='Balsamic vinegar'), (SELECT id FROM ingredient_categories WHERE name='Condiments & Sauces')),
((SELECT id FROM ingredients WHERE name='Vegetable stock'), (SELECT id FROM ingredient_categories WHERE name='Condiments & Sauces')),
((SELECT id FROM ingredients WHERE name='Olives'), (SELECT id FROM ingredient_categories WHERE name='Condiments & Sauces'));

-- Ingredient Synonyms (alternative names for better search)
INSERT IGNORE INTO ingredient_synonyms (ingredient_id, synonym) VALUES
-- Meat alternatives
((SELECT id FROM ingredients WHERE name='Minced beef'), 'ground beef'),
((SELECT id FROM ingredients WHERE name='Minced beef'), 'beef mince'),
((SELECT id FROM ingredients WHERE name='Minced beef'), 'hamburger meat'),

-- Plant milk alternatives
((SELECT id FROM ingredients WHERE name='Plant milk'), 'oat milk'),
((SELECT id FROM ingredients WHERE name='Plant milk'), 'almond milk'),
((SELECT id FROM ingredients WHERE name='Plant milk'), 'soy milk'),
((SELECT id FROM ingredients WHERE name='Plant milk'), 'coconut milk'),
((SELECT id FROM ingredients WHERE name='Plant milk'), 'non-dairy milk'),

-- Tomato variations
((SELECT id FROM ingredients WHERE name='Tomatoes'), 'fresh tomatoes'),
((SELECT id FROM ingredients WHERE name='Tomatoes'), 'ripe tomatoes'),
((SELECT id FROM ingredients WHERE name='Tomato'), 'cherry tomatoes'),
((SELECT id FROM ingredients WHERE name='Tomato sauce'), 'passata'),
((SELECT id FROM ingredients WHERE name='Tomato sauce'), 'marinara'),

-- Garlic variations
((SELECT id FROM ingredients WHERE name='Garlic'), 'garlic cloves'),
((SELECT id FROM ingredients WHERE name='Garlic'), 'fresh garlic'),

-- Flour variations
((SELECT id FROM ingredients WHERE name='Plain flour'), 'all-purpose flour'),
((SELECT id FROM ingredients WHERE name='Plain flour'), 'white flour'),
((SELECT id FROM ingredients WHERE name='Wholemeal base'), 'whole wheat base'),
((SELECT id FROM ingredients WHERE name='Wholemeal base'), 'brown base'),

-- Cheese variations
((SELECT id FROM ingredients WHERE name='Mozzarella'), 'fresh mozzarella'),
((SELECT id FROM ingredients WHERE name='Mozzarella'), 'buffalo mozzarella'),
((SELECT id FROM ingredients WHERE name='Feta'), 'feta cheese'),

-- Protein variations
((SELECT id FROM ingredients WHERE name='Chicken breast'), 'chicken fillets'),
((SELECT id FROM ingredients WHERE name='Chicken breast'), 'chicken breasts'),

-- Vegetable variations
((SELECT id FROM ingredients WHERE name='Bell pepper'), 'sweet pepper'),
((SELECT id FROM ingredients WHERE name='Bell pepper'), 'capsicum'),
((SELECT id FROM ingredients WHERE name='Mushroom'), 'mushrooms'),
((SELECT id FROM ingredients WHERE name='Mixed salad leaves'), 'salad mix'),
((SELECT id FROM ingredients WHERE name='Mixed salad leaves'), 'lettuce mix'),

-- Legume variations
((SELECT id FROM ingredients WHERE name='Chickpeas'), 'garbanzo beans'),
((SELECT id FROM ingredients WHERE name='Chickpeas'), 'canned chickpeas'),

-- Spice variations
((SELECT id FROM ingredients WHERE name='Ground cumin'), 'cumin powder'),
((SELECT id FROM ingredients WHERE name='Dried oregano'), 'oregano'),
((SELECT id FROM ingredients WHERE name='Curry powder'), 'curry spice'),

-- Baking variations
((SELECT id FROM ingredients WHERE name='Baking powder'), 'baking soda'),
((SELECT id FROM ingredients WHERE name='Maple syrup'), 'pure maple syrup'),
((SELECT id FROM ingredients WHERE name='Vanilla'), 'vanilla extract'),

-- Oil variations
((SELECT id FROM ingredients WHERE name='Olive oil'), 'extra virgin olive oil'),
((SELECT id FROM ingredients WHERE name='Olive oil'), 'EVOO'),

-- Fruit variations
((SELECT id FROM ingredients WHERE name='Lemon'), 'fresh lemon'),
((SELECT id FROM ingredients WHERE name='Lime'), 'fresh lime'),
((SELECT id FROM ingredients WHERE name='Mango'), 'ripe mango'),

-- Grain variations
((SELECT id FROM ingredients WHERE name='Basmati rice'), 'long grain rice'),
((SELECT id FROM ingredients WHERE name='Spaghetti'), 'pasta'),
((SELECT id FROM ingredients WHERE name='Couscous'), 'pearl couscous');

-- Ingredient Allergens (direct mapping to allergen dietary attributes)
INSERT IGNORE INTO ingredient_allergens (ingredient_id, dietary_attribute_id) VALUES
-- Gluten-containing ingredients (map to Gluten-Free restriction)
((SELECT id FROM ingredients WHERE name='Spaghetti'), (SELECT id FROM dietary_attributes WHERE name='Gluten-Free')),
((SELECT id FROM ingredients WHERE name='Plain flour'), (SELECT id FROM dietary_attributes WHERE name='Gluten-Free')),
((SELECT id FROM ingredients WHERE name='Wholemeal base'), (SELECT id FROM dietary_attributes WHERE name='Gluten-Free')),
((SELECT id FROM ingredients WHERE name='Pie crust'), (SELECT id FROM dietary_attributes WHERE name='Gluten-Free')),
((SELECT id FROM ingredients WHERE name='Flatbread'), (SELECT id FROM dietary_attributes WHERE name='Gluten-Free')),

-- Dairy-containing ingredients (map to Dairy-Free restriction)
((SELECT id FROM ingredients WHERE name='Mozzarella'), (SELECT id FROM dietary_attributes WHERE name='Dairy-Free')),
((SELECT id FROM ingredients WHERE name='Yogurt'), (SELECT id FROM dietary_attributes WHERE name='Dairy-Free')),
((SELECT id FROM ingredients WHERE name='Butter'), (SELECT id FROM dietary_attributes WHERE name='Dairy-Free')),
((SELECT id FROM ingredients WHERE name='Cream'), (SELECT id FROM dietary_attributes WHERE name='Dairy-Free')),
((SELECT id FROM ingredients WHERE name='Feta'), (SELECT id FROM dietary_attributes WHERE name='Dairy-Free')),

-- Egg-containing ingredients
((SELECT id FROM ingredients WHERE name='Eggs'), (SELECT id FROM dietary_attributes WHERE name='Egg-Free'));

-- Note: Plant milk, coconut cream are dairy alternatives and NOT linked to Dairy-Free restriction
-- Note: Many vegetables, herbs, and basic ingredients are naturally free from common allergens and don't need explicit mapping

-- Recipes
INSERT IGNORE INTO recipes (title, summary, difficulty) VALUES
('Spaghetti Bolognese','A comforting pasta with a rich tomato-beef sauce.','Easy'),
('Vegan Pancakes','Fluffy pancakes without dairy or eggs, perfect for brunch.','Easy'),
('Healthy Pizza','A lighter pizza with wholemeal base and colorful veg.','Medium'),
('Easy Lamb Biryani','Fragrant rice cooked with tender lamb and spices.','Medium'),
('Couscous Salad','Zesty couscous tossed with chickpeas and crisp veg.','Easy'),
('Plum clafoutis','Custardy baked dessert studded with ripe plums.','Medium');

-- Recipe categories (simplified)
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 1, id FROM categories WHERE name='Main';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 2, id FROM categories WHERE name='Dessert';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 2, id FROM categories WHERE name='Quick';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 3, id FROM categories WHERE name='Main';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 4, id FROM categories WHERE name='Main';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 5, id FROM categories WHERE name='Starter';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 5, id FROM categories WHERE name='Quick';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id)
SELECT 6, id FROM categories WHERE name='Dessert';

-- Recipe dietary attributes (structured dietary information) - consistent INSERT ... SELECT style
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegan' WHERE r.title='Vegan Pancakes';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Dairy-Free' WHERE r.title='Vegan Pancakes';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Egg-Free' WHERE r.title='Vegan Pancakes';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegetarian' WHERE r.title='Healthy Pizza';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegetarian' WHERE r.title='Couscous Salad';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='High-Protein' WHERE r.title='Couscous Salad';

-- Recipe ingredients & steps (invented)
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Spaghetti'),'200g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Minced beef'),'300g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Tomato sauce'),'400ml');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Onion'),'1 small, diced');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Garlic'),'2 cloves, minced');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Olive oil'),'1 tbsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Dried oregano'),'1 tsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Salt'),'to taste');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (1,(SELECT id FROM ingredients WHERE name='Black pepper'),'to taste');

INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
                                                                               (1,1,'Sauté onion and garlic in olive oil until soft.',5),
                                                                               (1,2,'Brown minced beef.',8),
                                                                               (1,3,'Stir in tomato sauce, oregano; simmer.',15),
                                                                               (1,4,'Cook spaghetti; combine with sauce and season.',10);

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (2,(SELECT id FROM ingredients WHERE name='Plain flour'),'150g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (2,(SELECT id FROM ingredients WHERE name='Plant milk'),'250ml');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (2,(SELECT id FROM ingredients WHERE name='Baking powder'),'1 tsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (2,(SELECT id FROM ingredients WHERE name='Maple syrup'),'1 tbsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (2,(SELECT id FROM ingredients WHERE name='Salt'),'pinch');

INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
                                                                               (2,1,'Whisk dry ingredients, then add plant milk and syrup.',5),
                                                                               (2,2,'Rest batter briefly.',5),
                                                                               (2,3,'Cook small ladles on a hot pan; flip when bubbles form.',10);

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (3,(SELECT id FROM ingredients WHERE name='Wholemeal base'),'1 medium');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (3,(SELECT id FROM ingredients WHERE name='Tomato sauce'),'4 tbsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (3,(SELECT id FROM ingredients WHERE name='Mozzarella'),'80g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (3,(SELECT id FROM ingredients WHERE name='Bell pepper'),'1 small, sliced');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (3,(SELECT id FROM ingredients WHERE name='Mushroom'),'4, sliced');

INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
                                                                               (3,1,'Spread tomato sauce on the base.',2),
                                                                               (3,2,'Top with vegetables and mozzarella.',3),
                                                                               (3,3,'Bake in hot oven until cheese melts.',12);

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (4,(SELECT id FROM ingredients WHERE name='Basmati rice'),'300g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (4,(SELECT id FROM ingredients WHERE name='Lamb'),'400g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (4,(SELECT id FROM ingredients WHERE name='Onion'),'1 large, sliced');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (4,(SELECT id FROM ingredients WHERE name='Curry powder'),'2 tsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (4,(SELECT id FROM ingredients WHERE name='Yogurt'),'100g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (4,(SELECT id FROM ingredients WHERE name='Salt'),'to taste');

INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
                                                                               (4,1,'Rinse rice; soak briefly.',10),
                                                                               (4,2,'Sauté onion; brown lamb with curry powder.',10),
                                                                               (4,3,'Layer lamb and rice; add yogurt and water, steam until tender.',25);

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Couscous'),'200g (dry)');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Chickpeas'),'200g, drained');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Cucumber'),'1/2, diced');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Lemon'),'1, juiced');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Olive oil'),'2 tbsp');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Salt'),'to taste');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (5,(SELECT id FROM ingredients WHERE name='Black pepper'),'to taste');

INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
                                                                               (5,1,'Hydrate couscous with hot water; fluff.',10),
                                                                               (5,2,'Toss with chickpeas, cucumber, lemon, oil, and seasoning.',5);

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (6,(SELECT id FROM ingredients WHERE name='Plums'),'6, halved');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (6,(SELECT id FROM ingredients WHERE name='Eggs'),'3');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (6,(SELECT id FROM ingredients WHERE name='Sugar'),'60g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (6,(SELECT id FROM ingredients WHERE name='Plain flour'),'60g');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (6,(SELECT id FROM ingredients WHERE name='Butter'),'20g, melted');
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity_text)
VALUES (6,(SELECT id FROM ingredients WHERE name='Plant milk'),'250ml');

INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
                                                                               (6,1,'Arrange plums in a buttered dish.',5),
                                                                               (6,2,'Blend eggs, sugar, flour, milk, and butter.',5),
                                                                               (6,3,'Pour over plums and bake until set.',30);

-- Demo favourites/ratings
INSERT IGNORE INTO favourites (user_id, recipe_id) VALUES (1,1), (1,2);
INSERT IGNORE INTO ratings (user_id, recipe_id, overall, taste, aesthetics, difficulty_score) VALUES (1,1,5,5,4,2),(1,2,4,4,4,1);

-- Extra seed: Mango Pie, Mushroom Doner
INSERT IGNORE INTO recipes (title, summary, difficulty) VALUES
                                                            ('Mango Pie','Bright, creamy mango filling in a crisp crust.','Medium'),
                                                            ('Mushroom Doner','Herbed mushrooms piled into warm flatbread with fresh veg.','Easy');

-- Categories link for new recipes
INSERT IGNORE INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Mango Pie' AND c.name='Dessert';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Mushroom Doner' AND c.name='Main';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Mushroom Doner' AND c.name='Quick';

-- Dietary attributes for new recipes (column-safe and idempotent)
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegetarian' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Dairy-Free' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegetarian' WHERE r.title='Mango Pie';

-- Mango Pie ingredients & steps
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'3 ripe, pureed' FROM recipes r JOIN ingredients i ON i.name='Mango' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 shell, baked' FROM recipes r JOIN ingredients i ON i.name='Pie crust' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1, zested' FROM recipes r JOIN ingredients i ON i.name='Lime' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tbsp' FROM recipes r JOIN ingredients i ON i.name='Cornflour' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'200 ml' FROM recipes r JOIN ingredients i ON i.name='Coconut cream' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tsp' FROM recipes r JOIN ingredients i ON i.name='Vanilla' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Sugar' WHERE r.title='Mango Pie';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Whisk mango puree with coconut cream, sugar, vanilla, lime, and cornflour.',10 FROM recipes WHERE title='Mango Pie';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Cook mixture over medium heat until thickened, stirring.',10 FROM recipes WHERE title='Mango Pie';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Pour into baked crust and chill until set.',60 FROM recipes WHERE title='Mango Pie';

-- Mushroom Doner ingredients & steps
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'300 g, thick slices' FROM recipes r JOIN ingredients i ON i.name='Mushroom' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tsp' FROM recipes r JOIN ingredients i ON i.name='Paprika' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tsp' FROM recipes r JOIN ingredients i ON i.name='Ground cumin' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Salt' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Black pepper' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tbsp' FROM recipes r JOIN ingredients i ON i.name='Olive oil' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2' FROM recipes r JOIN ingredients i ON i.name='Flatbread' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'handful, shredded' FROM recipes r JOIN ingredients i ON i.name='Lettuce' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1, sliced' FROM recipes r JOIN ingredients i ON i.name='Tomato' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tbsp, loosened with water' FROM recipes r JOIN ingredients i ON i.name='Tahini' WHERE r.title='Mushroom Doner';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Toss mushrooms with oil, paprika, cumin, salt and pepper.',5 FROM recipes WHERE title='Mushroom Doner';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Sear in a hot pan until browned and tender.',8 FROM recipes WHERE title='Mushroom Doner';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Warm flatbreads; fill with mushrooms, lettuce, tomato, and tahini.',5 FROM recipes WHERE title='Mushroom Doner';

-- Tag vocabulary (now purely free-form descriptive tags)
INSERT IGNORE INTO tags (name) VALUES ('30-minute'),('kid-friendly'),('low-cost'),('spicy'),('one-pan'),('comfort-food'),('party-food'),('meal-prep'),('romantic'),('family-style');

-- Tomato Basil Soup
INSERT IGNORE INTO recipes (title, summary, difficulty, image_url) VALUES
    ('Tomato Basil Soup','Simple, vibrant soup with fresh basil. Great starter.','Easy','/assets/images/tomato_basil_soup.jpg');
INSERT IGNORE INTO recipe_categories (recipe_id, category_id) SELECT r.id,c.id FROM recipes r,categories c WHERE r.title='Tomato Basil Soup' AND c.name='Starter';
INSERT IGNORE INTO recipe_categories (recipe_id, category_id) SELECT r.id,c.id FROM recipes r,categories c WHERE r.title='Tomato Basil Soup' AND c.name='Quick';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegetarian' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Dairy-Free' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Gluten-Free' WHERE r.title='Tomato Basil Soup';

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'500 g, chopped' FROM recipes r JOIN ingredients i ON i.name='Tomatoes' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'500 ml' FROM recipes r JOIN ingredients i ON i.name='Vegetable stock' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'handful' FROM recipes r JOIN ingredients i ON i.name='Basil' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tbsp' FROM recipes r JOIN ingredients i ON i.name='Olive oil' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Salt' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Black pepper' WHERE r.title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Sauté tomatoes in olive oil.',6 FROM recipes WHERE title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Add stock and simmer briefly.',8 FROM recipes WHERE title='Tomato Basil Soup';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Blend smooth, season and finish with basil.',4 FROM recipes WHERE title='Tomato Basil Soup';

-- Grilled Chicken Salad
INSERT IGNORE INTO recipes (title, summary, difficulty, image_url) VALUES
    ('Grilled Chicken Salad','Protein-forward salad with crisp veg and balsamic drizzle.','Easy','/assets/images/grilled_chicken_salad.jpg');
INSERT IGNORE INTO recipe_categories (recipe_id, category_id) SELECT r.id,c.id FROM recipes r,categories c WHERE r.title='Grilled Chicken Salad' AND c.name='Main';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Gluten-Free' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='High-Protein' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Low-Carb' WHERE r.title='Grilled Chicken Salad';

INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2, grilled and sliced' FROM recipes r JOIN ingredients i ON i.name='Chicken breast' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'3 cups' FROM recipes r JOIN ingredients i ON i.name='Mixed salad leaves' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'8, halved' FROM recipes r JOIN ingredients i ON i.name='Tomato' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'8, pitted' FROM recipes r JOIN ingredients i ON i.name='Olives' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'50 g, crumbled' FROM recipes r JOIN ingredients i ON i.name='Feta' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tbsp' FROM recipes r JOIN ingredients i ON i.name='Balsamic vinegar' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tbsp' FROM recipes r JOIN ingredients i ON i.name='Olive oil' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Salt' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Black pepper' WHERE r.title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Grill chicken until cooked through; rest.',12 FROM recipes WHERE title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Toss leaves with tomatoes, olives, feta, oil and balsamic.',5 FROM recipes WHERE title='Grilled Chicken Salad';
INSERT IGNORE INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Slice chicken and serve on top; season to taste.',3 FROM recipes WHERE title='Grilled Chicken Salad';

-- Enrich existing recipes with images, nutrition, and tags
UPDATE recipes SET image_url='/assets/images/spaghetti.jpg' WHERE title='Spaghetti Bolognese';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,620,32.0,75.0,22.0 FROM recipes WHERE title='Spaghetti Bolognese'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Spaghetti Bolognese' AND t.name IN ('kid-friendly','low-cost','comfort-food');

UPDATE recipes SET image_url='/assets/images/vegan_pancakes.jpg' WHERE title='Vegan Pancakes';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g)
SELECT id,280,6.0,48.0,7.0 FROM recipes WHERE title='Vegan Pancakes'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Vegan Pancakes' AND t.name IN ('30-minute','kid-friendly');

UPDATE recipes SET image_url='/assets/images/healthy_pizza.jpg' WHERE title='Healthy Pizza';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,510,24.0,60.0,18.0 FROM recipes WHERE title='Healthy Pizza'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Healthy Pizza' AND t.name IN ('kid-friendly','family-style');

UPDATE recipes SET image_url='/assets/images/lamb_biryani.jpg' WHERE title='Easy Lamb Biryani';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,700,35.0,80.0,25.0 FROM recipes WHERE title='Easy Lamb Biryani'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Easy Lamb Biryani' AND t.name IN ('spicy','one-pan');
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='High-Protein' WHERE r.title='Easy Lamb Biryani';

UPDATE recipes SET image_url='/assets/images/couscous_salad.jpg' WHERE title='Couscous Salad';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,420,14.0,60.0,12.0 FROM recipes WHERE title='Couscous Salad'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Couscous Salad' AND t.name IN ('30-minute','low-cost','meal-prep');

UPDATE recipes SET image_url='/assets/images/plum_clafoutis.jpg' WHERE title='Plum clafoutis';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,360,7.0,48.0,14.0 FROM recipes WHERE title='Plum clafoutis'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Plum clafoutis' AND t.name IN ('kid-friendly','comfort-food');
INSERT IGNORE INTO recipe_dietary_attributes (recipe_id, dietary_attribute_id)
SELECT r.id, da.id FROM recipes r JOIN dietary_attributes da ON da.name='Vegetarian' WHERE r.title='Plum clafoutis';

UPDATE recipes SET image_url='/assets/images/mango_pie.jpg' WHERE title='Mango Pie';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,420,5.0,55.0,18.0 FROM recipes WHERE title='Mango Pie'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Mango Pie' AND t.name IN ('kid-friendly','party-food');

UPDATE recipes SET image_url='/assets/images/mushroom_doner.jpg' WHERE title='Mushroom Doner';
INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,520,16.0,60.0,20.0 FROM recipes WHERE title='Mushroom Doner'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Mushroom Doner' AND t.name IN ('30-minute','comfort-food');

INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g)
SELECT id,180,4.0,20.0,9.0 FROM recipes WHERE title='Tomato Basil Soup'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Tomato Basil Soup' AND t.name IN ('30-minute','low-cost','one-pan','comfort-food');

INSERT IGNORE INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g)
SELECT id,430,38.0,10.0,24.0 FROM recipes WHERE title='Grilled Chicken Salad'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags (recipe_id, tag_id)
SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Grilled Chicken Salad' AND t.name IN ('30-minute','meal-prep');