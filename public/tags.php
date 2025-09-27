<?php
require_once __DIR__ . '/../app/includes/auth.php';
require_once __DIR__ . '/../app/includes/utils.php';
require_once __DIR__ . '/../app/includes/db.php';
require_once __DIR__ . '/../app/templates/header.php';

try { $tags = $pdo->query("SELECT id, name FROM tags ORDER BY name")->fetchAll(); }
catch (Throwable $th) { echo '<div class="card"><p>Tags are not available yet. Import <code>db/seed_all.sql</code> to enable tags.</p></div>'; require_once __DIR__ . '/../app/templates/footer.php'; exit; }

$tid = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($tid > 0) {
  $stmt = $pdo->prepare("
    SELECT r.id, r.title, r.image_url, COALESCE(AVG(rt.overall),0) as avg_rating,
           (SELECT SUM(minutes) FROM recipe_steps WHERE recipe_id = r.id) as total_time
    FROM recipe_tags rtg
    JOIN recipes r ON r.id = rtg.recipe_id
    LEFT JOIN ratings rt ON rt.recipe_id = r.id
    WHERE rtg.tag_id = ?
    GROUP BY r.id
    ORDER BY avg_rating DESC, r.title ASC
  ");
  $stmt->execute([$tid]);
  $recipes = $stmt->fetchAll();
  $name = null; foreach($tags as $t){ if ((int)$t['id']===$tid) { $name=$t['name']; break; } }
  echo '<h1>Tag: '.e($name ?? 'Unknown').'</h1>';
  if (!$recipes) { echo '<p class="meta">No recipes found for this tag.</p>'; }
  else {
    echo '<div class="grid cols-2">';
    foreach ($recipes as $r) {
      echo '<a class="card" href="recipe.php?id='.e($r['id']).'">';
      if (!empty($r['image_url'])) echo '<img src="'.e($r['image_url']).'" alt="" style="width:100%;height:160px;object-fit:cover;border-radius:6px;margin-bottom:.5rem;">';
      echo '<strong>'.e($r['title']).'</strong>';
      echo '<div class="meta">'.(int)$r['total_time'].' mins · ★ '.number_format((float)$r['avg_rating'],1).'</div>';
      echo '</a>';
    }
    echo '</div>';
  }
  echo '<p><a href="tags.php">← All tags</a></p>';
} else {
  echo '<h1>Browse by tag</h1><div class="grid cols-3">';
  foreach ($tags as $t) {
    echo '<a class="card" href="tags.php?id='.e($t['id']).'"><strong>'.e($t['name']).'</strong><div class="meta">View recipes</div></a>';
  }
  echo '</div>';
}
require_once __DIR__ . '/../app/templates/footer.php';
