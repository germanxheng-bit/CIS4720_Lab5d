/* ==========================================================================
   student_practice.sql
   CIS 4720 Database Management and SQL
   In Class Lab 5d

   WHAT THIS FILE IS
   Your working file for Lab 5d. The first two statements are written for
   you. Everything from Step 1 down is yours to write, under the heading
   that is already there for each step.

   HOW TO USE IT
   Run one statement at a time. Put the cursor on it and press Ctrl + E
   twice, or right click and choose Run Current Query. Do not run the whole
   file in one go, because Step 8 creates a function and that step has to be
   run as a single block on its own.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The headings below are already numbered, so keep
   your work underneath the right one. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these two first, in this order
-- =================================================================

-- Every schema on this server. Look for cis_students_db afterwards.
show databases;

-- Make the schema for this lab. IF NOT EXISTS means it is safe to run
-- twice, and it will not complain if you already made it.
create database if not exists cis_students_db;


-- =================================================================
-- POINT YOURSELF AT THE NEW SCHEMA
-- =================================================================

-- Everything below has to land in cis_students_db, not in the schema you
-- connected to. This line switches the session over.
--
-- IMPORTANT: if your tables keep appearing in the wrong place, your tool
-- is opening a new connection for each statement and this line is being
-- forgotten. Step 3 of the lab tells you how to fix that for good by
-- adding a second SQLTools connection that points at cis_students_db.
use cis_students_db;


-- ######################################################################
-- YOUR WORK STARTS BELOW THIS LINE
--
-- You write the SQL for Steps 1 through 7 yourself. The handout gives you
-- the specification, the data and the result you should get.
--
-- Steps 8, 9 and 10 are printed in the handout for you to copy, because
-- you have not written a function or a trigger before.
--
-- STEPS 8 AND 10 ARE RUN AT THE COMMAND PROMPT, not in VS Code. They
-- start with DELIMITER, which is an instruction to the command prompt
-- program rather than SQL, so the server rejects it. The handout says
-- what to do. Everything else in this file runs in VS Code as usual.
-- ######################################################################


-- =================================================================
-- STEP 1. Create the students table, then describe it
-- =================================================================

-- Create the students table with an auto-incrementing primary key
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    gpa FLOAT(4, 2)
);

-- Describe the table to verify columns and properties
DESCRIBE students;


-- =================================================================
-- STEP 2. Insert four rows using NULL for student_id and gpa
-- =================================================================

-- Insert the first four student rows
INSERT INTO students (student_id, first_name, last_name, gpa) VALUES
(NULL, 'Jenna', 'Wilson', NULL),
(NULL, 'Robert', 'Reese', NULL),
(NULL, 'Maria Elena', 'Jimenez', NULL),
(NULL, 'Inder', 'Singh', NULL);

-- Check the last generated insert ID (1) and view the table)
SELECT last_insert_id();
SELECT * FROM students;


-- =================================================================
-- STEP 3. Insert two more rows, naming the columns first
-- =================================================================

-- Insert two more rows and naming the columns
INSERT INTO students (first_name, last_name) VALUES
('Rita', 'Nunez'),
('James', 'Toor');

-- Check the last insert ID and view the updated table (six rows total)
SELECT last_insert_id();
SELECT * FROM students;


-- =================================================================
-- STEP 4. Delete James Toor
-- =================================================================

-- Delete James Toor by testing with SELECT first, then deleting
SELECT * FROM students WHERE first_name = 'James' AND last_name = 'Toor';
DELETE FROM students WHERE first_name = 'James' AND last_name = 'Toor';

-- View the remaining 5 rows
SELECT * FROM students;


-- =================================================================
-- STEP 5. Create the test_scores table
-- =================================================================

-- Create the test_scores table with a foreign key
CREATE TABLE test_scores (
   test_score_id INT AUTO_INCREMENT PRIMARY KEY,
   test_name VARCHAR(20) NOT NULL,
   student_id INT NOT NULL,
   score FLOAT,
   FOREIGN KEY (student_id) REFERENCES students(student_id)
);


-- =================================================================
-- STEP 6. Insert the ten test score rows
-- =================================================================

-- Insert the ten test score rows in one statement
INSERT INTO test_scores (test_name, student_id, score) VALUES
('quiz1', 1, 90),
('quiz1', 2, 85),
('quiz1', 3, 95),
('quiz2', 1, 80),
('quiz2', 2, 72),
('quiz2', 3, 88),
('quiz2', 4, 91),
('quiz3', 2, 95),
('quiz3', 3, 94),
('quiz3', 4, 74);

-- View all records in test_scores
SELECT * FROM test_scores;


-- =================================================================
-- STEP 7. Create the student_scores view from a LEFT OUTER JOIN,
--         then query it twice
-- =================================================================

-- Create a view using a LEFT OUTER JOIN to keep all students (including Rita with no scores)
CREATE VIEW student_scores AS
SELECT
   s.student_id,
   CONCAT(s.first_name, ' ', s.last_name) AS student_name,
   t.test_name,
   t.score
FROM students s
LEFT OUTER JOIN test_scores t ON s.student_id = t.student_id;

-- Query the entire view (should show 11 rows, with NULLs for Rita Nunez)
SELECT * FROM student_scores;

-- Query the view for a single student (student_id = 3, Maria Elena Jimenez)
SELECT * FROM student_scores WHERE student_id = 3;


-- =================================================================
-- STEP 8. Create the calculate_gpa function
--
-- Paste the block from the handout in here so it is part of what you
-- submit, then RUN IT AT THE COMMAND PROMPT, not in VS Code.
--
-- DELIMITER is an instruction to the mysql command prompt program. It is
-- not SQL. Run it here and the server rejects it with
--   ERROR 1064 ... near 'DELIMITER $$' at line 1
-- =================================================================

-- Creates a stored function named calculate_gpa
-- stop treating ; as the end of a statement, and use $$ instead,
-- so the semicolons inside the function do not cut it short
DELIMITER $$
-- name the function and say it takes one argument, a student id
CREATE FUNCTION calculate_gpa(p_student_id INT)
-- the single value it hands back is a number with 2 decimal places
RETURNS DECIMAL(4,2)
-- promise that the same id always produces the same answer
DETERMINISTIC
-- it queries a table but never changes one
READS SQL DATA
-- the body starts here
BEGIN
-- a variable to hold the answer while we work it out
DECLARE v_gpa DECIMAL(4,2);
-- average that student's scores, rounded to 2 decimal places
SELECT ROUND(AVG(score), 2)
-- and put the result into the variable instead of returning it
INTO v_gpa
FROM test_scores
-- only this student's rows
WHERE student_id = p_student_id
-- and ignore any row with no score recorded
AND score IS NOT NULL;
-- hand back the answer. a student with no scores averages to
-- NULL, so IFNULL turns that into 0.00 rather than nothing
RETURN IFNULL(v_gpa, 0.00);
END$$
-- put the delimiter back to a semicolon for everything that follows
DELIMITER ;

-- Confirm the function created properly
show create function calculate_gpa;


-- =================================================================
-- STEP 9. Run the function and fill in every gpa
-- =================================================================

-- Run the function to update every student's GPA and check the results
UPDATE students
SET gpa = calculate_gpa(student_id);

SELECT * FROM students;


-- =================================================================
-- STEP 10. Create the triggers that recalculate the gpa
--
-- Same as Step 8. Paste the block in here, then run it at the command
-- prompt. Afterwards add a score or change one, back here in VS Code,
-- and check that the gpa moved on its own.
-- =================================================================

-- Create triggers to automatically recalculate GPAs on inserts and updates
-- $$ again, because a trigger body has semicolons in it too
DELIMITER $$
-- fires after a row is ADDED to test_scores
CREATE TRIGGER trg_scores_after_insert
AFTER INSERT ON test_scores
-- once for every row the statement touched, not once per statement
FOR EACH ROW
BEGIN
-- NEW is the row that was just inserted, so NEW.student_id is
-- whichever student that score belongs to
UPDATE students
SET gpa = calculate_gpa(NEW.student_id)
WHERE student_id = NEW.student_id;
END$$
-- and the same again for a score being CHANGED
CREATE TRIGGER trg_scores_after_update
AFTER UPDATE ON test_scores
FOR EACH ROW
BEGIN
UPDATE students
SET gpa = calculate_gpa(NEW.student_id)
WHERE student_id = NEW.student_id;
END$$
DELIMITER ;

-- Check that both triggers are registered
SHOW TRIGGERS;

-- Test the trigger by inserting a new test score for student 1 (Jenna Wilson)
INSERT INTO test_scores (test_name, student_id, score) VALUES
('quiz4', 1, 100);

-- Verify that Jenna's GPA updated
SELECT * FROM students;
SELECT * FROM student_scores;


-- =================================================================
-- STEP 11. Push this file to GitHub
-- Nothing to write here. Follow the handout.
-- =================================================================
