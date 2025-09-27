<?php
require_once __DIR__ . '/../app/includes/auth.php'; require_once __DIR__ . '/../app/includes/utils.php'; require_once __DIR__ . '/../app/includes/db.php';
require_login(); require_once __DIR__ . '/../app/templates/header.php';
$st=$pdo->prepare("
SELECT r.id, r.title, r.difficulty, r.image_url, COALESCE(AVG(rt.overall),0) avg_rating,
       (SELECT SUM(minutes) FROM recipe_steps WHERE recipe_id=r.id) total_time
FROM favourites f
JOIN recipes r ON r.id=f.recipe_id
LEFT JOIN ratings rt ON rt.recipe_id=r.id
WHERE f.user_id=?
GROUP BY r.id
ORDER BY r.title");
$st->execute([current_user_id()]); $items=$st->fetchAll();
?><h1>Your Favourites</h1>
<?php if(!$items): ?><p class="meta">You have no favourites yet.</p>
<?php else: ?><div class="grid cols-2"><?php foreach($items as $r): ?>
<a class="card" href="recipe.php?id=<?= e($r['id'])?>"><?php if(!empty($r['image_url'])): ?><img src="<?= e($r['image_url'])?>" alt="" style="width:100%;height:160px;object-fit:cover;border-radius:6px;margin-bottom:.5rem;"><?php endif; ?><strong><?= e($r['title'])?></strong><div class="meta"><?= e($r['difficulty'])?> · <?= (int)$r['total_time'] ?> mins · ★ <?= number_format((float)$r['avg_rating'], 1) ?></div></a>
<?php endforeach; ?></div><?php endif; ?>
<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>
