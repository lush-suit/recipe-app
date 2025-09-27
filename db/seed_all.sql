-- seed_all.sql (complete with dietary_attributes)
-- This file includes all seed data with the new dietary_attributes structure.

-- Categories (focused on meal types and course classification)
INSERT INTO categories(name) VALUES ('Starter'),('Main'),('Dessert'),('Quick'),('Budget');

-- Enhanced Dietary Attributes with categorization
INSERT INTO dietary_attributes(name, description, display_order, category, severity, is_exclusion, icon) VALUES
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
INSERT INTO users(name,email,password_hash) VALUES ('Demo User','demo@example.com','$2y$10$Kp7T8r7j4xQ0Q9d2Z2g8W.zvZ3C2l2Vq1o6a3xM1r6R9y2b1QmJk2');

-- Ingredients
INSERT INTO ingredients(name) VALUES
    ('Spaghetti'),('Minced beef'),('Tomato sauce'),('Onion'),('Garlic'),('Olive oil'),('Dried oregano'),('Salt'),('Black pepper'),
    ('Plain flour'),('Plant milk'),('Baking powder'),('Maple syrup'),
    ('Wholemeal base'),('Mozzarella'),('Bell pepper'),('Mushroom'),
    ('Basmati rice'),('Lamb'),('Curry powder'),('Yogurt'),
    ('Couscous'),('Chickpeas'),('Cucumber'),('Lemon'),
    ('Plums'),('Eggs'),('Sugar'),('Butter');

-- Recipes
INSERT INTO recipes (title, summary, difficulty) VALUES
    ('Spaghetti Bolognese','A comforting pasta with a rich tomato-beef sauce.','Easy'),
    ('Vegan Pancakes','Fluffy pancakes without dairy or eggs, perfect for brunch.','Easy'),
    ('Healthy Pizza','A lighter pizza with wholemeal base and colorful veg.','Medium'),
    ('Easy Lamb Biryani','Fragrant rice cooked with tender lamb and spices.','Medium'),
    ('Couscous Salad','Zesty couscous tossed with chickpeas and crisp veg.','Easy'),
    ('Plum clafoutis','Custardy baked dessert studded with ripe plums.','Medium');

-- Recipe categories (simplified)
INSERT INTO recipe_categories VALUES (1,(SELECT id FROM categories WHERE name='Main'));
INSERT INTO recipe_categories VALUES (2,(SELECT id FROM categories WHERE name='Dessert'));
INSERT INTO recipe_categories VALUES (2,(SELECT id FROM categories WHERE name='Quick'));
INSERT INTO recipe_categories VALUES (3,(SELECT id FROM categories WHERE name='Main'));
INSERT INTO recipe_categories VALUES (4,(SELECT id FROM categories WHERE name='Main'));
INSERT INTO recipe_categories VALUES (5,(SELECT id FROM categories WHERE name='Starter'));
INSERT INTO recipe_categories VALUES (5,(SELECT id FROM categories WHERE name='Quick'));
INSERT INTO recipe_categories VALUES (6,(SELECT id FROM categories WHERE name='Dessert'));

-- Recipe dietary attributes (structured dietary information)
INSERT INTO recipe_dietary_attributes VALUES (2,(SELECT id FROM dietary_attributes WHERE name='Vegan'));
INSERT INTO recipe_dietary_attributes VALUES (2,(SELECT id FROM dietary_attributes WHERE name='Dairy-Free'));
INSERT INTO recipe_dietary_attributes VALUES (2,(SELECT id FROM dietary_attributes WHERE name='Egg-Free'));
INSERT INTO recipe_dietary_attributes VALUES (3,(SELECT id FROM dietary_attributes WHERE name='Vegetarian'));
INSERT INTO recipe_dietary_attributes VALUES (5,(SELECT id FROM dietary_attributes WHERE name='Vegetarian'));
INSERT INTO recipe_dietary_attributes VALUES (5,(SELECT id FROM dietary_attributes WHERE name='High-Protein'));

-- Recipe ingredients & steps (invented)
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Spaghetti'),'200g');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Minced beef'),'300g');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Tomato sauce'),'400ml');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Onion'),'1 small, diced');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Garlic'),'2 cloves, minced');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Olive oil'),'1 tbsp');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Dried oregano'),'1 tsp');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Salt'),'to taste');
INSERT INTO recipe_ingredients VALUES (1,(SELECT id FROM ingredients WHERE name='Black pepper'),'to taste');
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
    (1,1,'Sauté onion and garlic in olive oil until soft.',5),
    (1,2,'Brown minced beef.',8),
    (1,3,'Stir in tomato sauce, oregano; simmer.',15),
    (1,4,'Cook spaghetti; combine with sauce and season.',10);

-- Vegan Pancakes
INSERT INTO recipe_ingredients VALUES (2,(SELECT id FROM ingredients WHERE name='Plain flour'),'150g');
INSERT INTO recipe_ingredients VALUES (2,(SELECT id FROM ingredients WHERE name='Plant milk'),'250ml');
INSERT INTO recipe_ingredients VALUES (2,(SELECT id FROM ingredients WHERE name='Baking powder'),'1 tsp');
INSERT INTO recipe_ingredients VALUES (2,(SELECT id FROM ingredients WHERE name='Maple syrup'),'1 tbsp');
INSERT INTO recipe_ingredients VALUES (2,(SELECT id FROM ingredients WHERE name='Salt'),'pinch');
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
    (2,1,'Whisk dry ingredients, then add plant milk and syrup.',5),
    (2,2,'Rest batter briefly.',5),
    (2,3,'Cook small ladles on a hot pan; flip when bubbles form.',10);

-- Healthy Pizza
INSERT INTO recipe_ingredients VALUES (3,(SELECT id FROM ingredients WHERE name='Wholemeal base'),'1 medium');
INSERT INTO recipe_ingredients VALUES (3,(SELECT id FROM ingredients WHERE name='Tomato sauce'),'4 tbsp');
INSERT INTO recipe_ingredients VALUES (3,(SELECT id FROM ingredients WHERE name='Mozzarella'),'80g');
INSERT INTO recipe_ingredients VALUES (3,(SELECT id FROM ingredients WHERE name='Bell pepper'),'1 small, sliced');
INSERT INTO recipe_ingredients VALUES (3,(SELECT id FROM ingredients WHERE name='Mushroom'),'4, sliced');
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
    (3,1,'Spread tomato sauce on the base.',2),
    (3,2,'Top with vegetables and mozzarella.',3),
    (3,3,'Bake in hot oven until cheese melts.',12);

-- Easy Lamb Biryani
INSERT INTO recipe_ingredients VALUES (4,(SELECT id FROM ingredients WHERE name='Basmati rice'),'300g');
INSERT INTO recipe_ingredients VALUES (4,(SELECT id FROM ingredients WHERE name='Lamb'),'400g');
INSERT INTO recipe_ingredients VALUES (4,(SELECT id FROM ingredients WHERE name='Onion'),'1 large, sliced');
INSERT INTO recipe_ingredients VALUES (4,(SELECT id FROM ingredients WHERE name='Curry powder'),'2 tsp');
INSERT INTO recipe_ingredients VALUES (4,(SELECT id FROM ingredients WHERE name='Yogurt'),'100g');
INSERT INTO recipe_ingredients VALUES (4,(SELECT id FROM ingredients WHERE name='Salt'),'to taste');
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
    (4,1,'Rinse rice; soak briefly.',10),
    (4,2,'Sauté onion; brown lamb with curry powder.',10),
    (4,3,'Layer lamb and rice; add yogurt and water, steam until tender.',25);

-- Couscous Salad
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Couscous'),'200g (dry)');
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Chickpeas'),'200g, drained');
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Cucumber'),'1/2, diced');
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Lemon'),'1, juiced');
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Olive oil'),'2 tbsp');
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Salt'),'to taste');
INSERT INTO recipe_ingredients VALUES (5,(SELECT id FROM ingredients WHERE name='Black pepper'),'to taste');
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
    (5,1,'Hydrate couscous with hot water; fluff.',10),
    (5,2,'Toss with chickpeas, cucumber, lemon, oil, and seasoning.',5);

-- Plum clafoutis
INSERT INTO recipe_ingredients VALUES (6,(SELECT id FROM ingredients WHERE name='Plums'),'6, halved');
INSERT INTO recipe_ingredients VALUES (6,(SELECT id FROM ingredients WHERE name='Eggs'),'3');
INSERT INTO recipe_ingredients VALUES (6,(SELECT id FROM ingredients WHERE name='Sugar'),'60g');
INSERT INTO recipe_ingredients VALUES (6,(SELECT id FROM ingredients WHERE name='Plain flour'),'60g');
INSERT INTO recipe_ingredients VALUES (6,(SELECT id FROM ingredients WHERE name='Butter'),'20g, melted');
INSERT INTO recipe_ingredients VALUES (6,(SELECT id FROM ingredients WHERE name='Plant milk'),'250ml');
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) VALUES
    (6,1,'Arrange plums in a buttered dish.',5),
    (6,2,'Blend eggs, sugar, flour, milk, and butter.',5),
    (6,3,'Pour over plums and bake until set.',30);

-- Demo favourites/ratings
INSERT INTO favourites (user_id, recipe_id) VALUES (1,1), (1,2);
INSERT INTO ratings (user_id, recipe_id, overall, taste, aesthetics, difficulty_score) VALUES (1,1,5,5,4,2),(1,2,4,4,4,1);

-- Extra seed: Mango Pie, Mushroom Doner
INSERT IGNORE INTO ingredients(name) VALUES ('Mango'),('Pie crust'),('Lime'),('Cornflour'),('Coconut cream'),('Vanilla'),
('Flatbread'),('Paprika'),('Ground cumin'),('Tahini'),('Lettuce'),('Tomato');

INSERT INTO recipes (title, summary, difficulty) VALUES
('Mango Pie','Bright, creamy mango filling in a crisp crust.','Medium'),
('Mushroom Doner','Herbed mushrooms piled into warm flatbread with fresh veg.','Easy');

-- Categories link for new recipes
INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Mango Pie' AND c.name='Dessert';
INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Mushroom Doner' AND c.name='Main';
INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Mushroom Doner' AND c.name='Quick';

-- Dietary attributes for new recipes
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Mushroom Doner'),(SELECT id FROM dietary_attributes WHERE name='Vegetarian'));
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Mushroom Doner'),(SELECT id FROM dietary_attributes WHERE name='Dairy-Free'));
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Mango Pie'),(SELECT id FROM dietary_attributes WHERE name='Vegetarian'));

-- Mango Pie ingredients & steps
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'3 ripe, pureed' FROM recipes r JOIN ingredients i ON i.name='Mango' WHERE r.title='Mango Pie';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 shell, baked' FROM recipes r JOIN ingredients i ON i.name='Pie crust' WHERE r.title='Mango Pie';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1, zested' FROM recipes r JOIN ingredients i ON i.name='Lime' WHERE r.title='Mango Pie';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tbsp' FROM recipes r JOIN ingredients i ON i.name='Cornflour' WHERE r.title='Mango Pie';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'200 ml' FROM recipes r JOIN ingredients i ON i.name='Coconut cream' WHERE r.title='Mango Pie';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tsp' FROM recipes r JOIN ingredients i ON i.name='Vanilla' WHERE r.title='Mango Pie';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Sugar' WHERE r.title='Mango Pie';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Whisk mango puree with coconut cream, sugar, vanilla, lime, and cornflour.',10 FROM recipes WHERE title='Mango Pie';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Cook mixture over medium heat until thickened, stirring.',10 FROM recipes WHERE title='Mango Pie';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Pour into baked crust and chill until set.',60 FROM recipes WHERE title='Mango Pie';

-- Mushroom Doner ingredients & steps
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'300 g, thick slices' FROM recipes r JOIN ingredients i ON i.name='Mushroom' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tsp' FROM recipes r JOIN ingredients i ON i.name='Paprika' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tsp' FROM recipes r JOIN ingredients i ON i.name='Ground cumin' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Salt' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Black pepper' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tbsp' FROM recipes r JOIN ingredients i ON i.name='Olive oil' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2' FROM recipes r JOIN ingredients i ON i.name='Flatbread' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'handful, shredded' FROM recipes r JOIN ingredients i ON i.name='Lettuce' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1, sliced' FROM recipes r JOIN ingredients i ON i.name='Tomato' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tbsp, loosened with water' FROM recipes r JOIN ingredients i ON i.name='Tahini' WHERE r.title='Mushroom Doner';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Toss mushrooms with oil, paprika, cumin, salt and pepper.',5 FROM recipes WHERE title='Mushroom Doner';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Sear in a hot pan until browned and tender.',8 FROM recipes WHERE title='Mushroom Doner';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Warm flatbreads; fill with mushrooms, lettuce, tomato, and tahini.',5 FROM recipes WHERE title='Mushroom Doner';

-- Tag vocabulary (now purely free-form descriptive tags)
INSERT IGNORE INTO tags (name) VALUES ('30-minute'),('kid-friendly'),('low-cost'),('spicy'),('one-pan'),('comfort-food'),('party-food'),('meal-prep'),('romantic'),('family-style');

-- Additional ingredients for extended recipes
INSERT IGNORE INTO ingredients(name) VALUES ('Tomatoes'),('Vegetable stock'),('Basil'),('Cream'),
                                            ('Chicken breast'),('Mixed salad leaves'),('Olives'),('Feta'),('Balsamic vinegar');

-- Tomato Basil Soup
INSERT INTO recipes (title, summary, difficulty, image_url) VALUES
    ('Tomato Basil Soup','Simple, vibrant soup with fresh basil. Great starter.','Easy','/assets/images/tomato_basil_soup.jpg');
INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id,c.id FROM recipes r,categories c WHERE r.title='Tomato Basil Soup' AND c.name='Starter';
INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id,c.id FROM recipes r,categories c WHERE r.title='Tomato Basil Soup' AND c.name='Quick';
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Tomato Basil Soup'),(SELECT id FROM dietary_attributes WHERE name='Vegetarian'));
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Tomato Basil Soup'),(SELECT id FROM dietary_attributes WHERE name='Dairy-Free'));
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Tomato Basil Soup'),(SELECT id FROM dietary_attributes WHERE name='Gluten-Free'));

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'500 g, chopped' FROM recipes r JOIN ingredients i ON i.name='Tomatoes' WHERE r.title='Tomato Basil Soup';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'500 ml' FROM recipes r JOIN ingredients i ON i.name='Vegetable stock' WHERE r.title='Tomato Basil Soup';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'handful' FROM recipes r JOIN ingredients i ON i.name='Basil' WHERE r.title='Tomato Basil Soup';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tbsp' FROM recipes r JOIN ingredients i ON i.name='Olive oil' WHERE r.title='Tomato Basil Soup';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Salt' WHERE r.title='Tomato Basil Soup';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Black pepper' WHERE r.title='Tomato Basil Soup';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Sauté tomatoes in olive oil.',6 FROM recipes WHERE title='Tomato Basil Soup';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Add stock and simmer briefly.',8 FROM recipes WHERE title='Tomato Basil Soup';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Blend smooth, season and finish with basil.',4 FROM recipes WHERE title='Tomato Basil Soup';

-- Grilled Chicken Salad
INSERT INTO recipes (title, summary, difficulty, image_url) VALUES
    ('Grilled Chicken Salad','Protein-forward salad with crisp veg and balsamic drizzle.','Easy','/assets/images/grilled_chicken_salad.jpg');
INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id,c.id FROM recipes r,categories c WHERE r.title='Grilled Chicken Salad' AND c.name='Main';
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Grilled Chicken Salad'),(SELECT id FROM dietary_attributes WHERE name='Gluten-Free'));
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Grilled Chicken Salad'),(SELECT id FROM dietary_attributes WHERE name='High-Protein'));
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Grilled Chicken Salad'),(SELECT id FROM dietary_attributes WHERE name='Low-Carb'));

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2, grilled and sliced' FROM recipes r JOIN ingredients i ON i.name='Chicken breast' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'3 cups' FROM recipes r JOIN ingredients i ON i.name='Mixed salad leaves' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'8, halved' FROM recipes r JOIN ingredients i ON i.name='Tomato' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'8, pitted' FROM recipes r JOIN ingredients i ON i.name='Olives' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'50 g, crumbled' FROM recipes r JOIN ingredients i ON i.name='Feta' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'2 tbsp' FROM recipes r JOIN ingredients i ON i.name='Balsamic vinegar' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'1 tbsp' FROM recipes r JOIN ingredients i ON i.name='Olive oil' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Salt' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) SELECT r.id,i.id,'to taste' FROM recipes r JOIN ingredients i ON i.name='Black pepper' WHERE r.title='Grilled Chicken Salad';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,1,'Grill chicken until cooked through; rest.',12 FROM recipes WHERE title='Grilled Chicken Salad';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,2,'Toss leaves with tomatoes, olives, feta, oil and balsamic.',5 FROM recipes WHERE title='Grilled Chicken Salad';
INSERT INTO recipe_steps (recipe_id, step_no, instruction, minutes) SELECT id,3,'Slice chicken and serve on top; season to taste.',3 FROM recipes WHERE title='Grilled Chicken Salad';

-- Enrich existing recipes with images, nutrition, and tags
UPDATE recipes SET image_url='/assets/images/spaghetti.jpg' WHERE title='Spaghetti Bolognese';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,620,32.0,75.0,22.0 FROM recipes WHERE title='Spaghetti Bolognese'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Spaghetti Bolognese' AND t.name IN ('kid-friendly','low-cost','comfort-food');

UPDATE recipes SET image_url='/assets/images/vegan_pancakes.jpg' WHERE title='Vegan Pancakes';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,280,6.0,48.0,7.0 FROM recipes WHERE title='Vegan Pancakes'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Vegan Pancakes' AND t.name IN ('30-minute','kid-friendly');

UPDATE recipes SET image_url='/assets/images/healthy_pizza.jpg' WHERE title='Healthy Pizza';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,510,24.0,60.0,18.0 FROM recipes WHERE title='Healthy Pizza'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Healthy Pizza' AND t.name IN ('kid-friendly','family-style');

UPDATE recipes SET image_url='/assets/images/lamb_biryani.jpg' WHERE title='Easy Lamb Biryani';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,700,35.0,80.0,25.0 FROM recipes WHERE title='Easy Lamb Biryani'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Easy Lamb Biryani' AND t.name IN ('spicy','one-pan');
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Easy Lamb Biryani'),(SELECT id FROM dietary_attributes WHERE name='High-Protein'));

UPDATE recipes SET image_url='/assets/images/couscous_salad.jpg' WHERE title='Couscous Salad';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,420,14.0,60.0,12.0 FROM recipes WHERE title='Couscous Salad'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Couscous Salad' AND t.name IN ('30-minute','low-cost','meal-prep');

UPDATE recipes SET image_url='/assets/images/plum_clafoutis.jpg' WHERE title='Plum clafoutis';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,360,7.0,48.0,14.0 FROM recipes WHERE title='Plum clafoutis'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Plum clafoutis' AND t.name IN ('kid-friendly','comfort-food');
INSERT INTO recipe_dietary_attributes VALUES ((SELECT id FROM recipes WHERE title='Plum clafoutis'),(SELECT id FROM dietary_attributes WHERE name='Vegetarian'));

UPDATE recipes SET image_url='/assets/images/mango_pie.jpg' WHERE title='Mango Pie';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,420,5.0,55.0,18.0 FROM recipes WHERE title='Mango Pie'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Mango Pie' AND t.name IN ('kid-friendly','party-food');

UPDATE recipes SET image_url='/assets/images/mushroom_doner.jpg' WHERE title='Mushroom Doner';
INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,520,16.0,60.0,20.0 FROM recipes WHERE title='Mushroom Doner'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Mushroom Doner' AND t.name IN ('30-minute','comfort-food');

INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,180,4.0,20.0,9.0 FROM recipes WHERE title='Tomato Basil Soup'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Tomato Basil Soup' AND t.name IN ('30-minute','low-cost','one-pan','comfort-food');

INSERT INTO nutrition (recipe_id, calories_kcal, protein_g, carbs_g, fat_g) SELECT id,430,38.0,10.0,24.0 FROM recipes WHERE title='Grilled Chicken Salad'
ON DUPLICATE KEY UPDATE calories_kcal=VALUES(calories_kcal), protein_g=VALUES(protein_g), carbs_g=VALUES(carbs_g), fat_g=VALUES(fat_g);
INSERT IGNORE INTO recipe_tags SELECT r.id, t.id FROM recipes r, tags t WHERE r.title='Grilled Chicken Salad' AND t.name IN ('30-minute','meal-prep');