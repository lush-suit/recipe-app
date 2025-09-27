# Recipe Web App (PHP 8 + MySQL, XAMPP)

A minimal, accessible, responsive Recipe Web App that satisfies the assignment brief.

**PHP Version Requirement:** This project requires PHP **7.4 or newer**, with PHP **8.2+ recommended** (works with the latest XAMPP release).

## Quick Start (Windows + XAMPP)
1. Start **Apache** and **MySQL**.
2. Create a database named `recipe_app` in phpMyAdmin.
3. Import `db/schema.sql`.
4. Import **one file**: `db/seed_all.sql` (this already includes everything from `seed.sql`, `seed_extra.sql`, and `seed_extras_2.sql`).
5. Copy this folder to `C:\xampp\htdocs\recipe_web_app`.
6. Edit `app/config.example.php` → save as `app/config.php` with your DB credentials.
7. Visit http://localhost/recipe_web_app/

### Default test user
- Email: `demo@example.com`
- Password: `Password123!`

## Notes
- Seed data is original and invented (safe for coursework). Replace with your own content as needed.
- No front-end frameworks; HTML5/CSS3/vanilla JS only.

## Makefile shortcuts for Liquibase
Use Dockerized Liquibase quickly:
```bash
make db-status
make db-update
make db-baseline
make db-diff
make db-diff-changelog
```

## YAML changesets with rollbacks
Each `db/migrations/*.sql` now has a corresponding YAML changeset in `liquibase/changelogs/` with a basic rollback stub (table drops where detectable).
