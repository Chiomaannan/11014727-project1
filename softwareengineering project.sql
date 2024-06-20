-- -- Create Students table with 8-digit student_id
CREATE TABLE students (
    student_id CHAR(8) PRIMARY KEY,
     first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(15),
    address TEXT
);
 -- Insert sample data into Students table
INSERT INTO students (student_id, first_name, last_name, email, phone_number, address) VALUES
('11384899', 'Chioma', 'Annan', 'chioma.annan@gmail.com', '233507149094', '123 Paw St'),
('11036846', 'Vanessa', 'Ofori', 'vanessa.ofori@gmail.com', '233507149095', '456 Eve St');


-- Create Fees table with reference to 8-digit student_id
CREATE TABLE fees (
    fee_id SERIAL PRIMARY KEY,
    student_id CHAR(8) REFERENCES students(student_id),
    amount DECIMAL(10, 2),
    payment_date DATE,
    description TEXT
);
-- Insert sample data into Fees table
INSERT INTO fees (student_id, amount, payment_date, description) VALUES
('11384899', 1500.00, '2024-01-15', 'Tuition Fee'),
('11036846', 1500.00, '2024-01-15', 'Tuition Fee');

-- Create Courses table
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100),
    course_code VARCHAR(10),
    credits INT
);

-- Insert sample data into Courses table
INSERT INTO courses (course_name, course_code, credits) VALUES
('Database Systems', 'CPEN202', 3),
('Operating Systems', 'CPEN212', 3),
('Algorithms', 'CPEN204', 3);

-- Create Enrollments table with reference to 8-digit student_id
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id CHAR(8) REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    enrollment_date DATE
);
-- Insert sample data into Enrollments table
INSERT INTO enrollments (student_id, course_id, enrollment_date) VALUES
('11384899', 1, '2024-01-20'),
('11036846', 2, '2024-01-20');

-- Create Lecturers table
CREATE TABLE lecturers (
    lecturer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(15),
    department VARCHAR(100)
);
-- Insert sample data into Lecturers table
INSERT INTO lecturers (first_name, last_name, email, phone_number, department) VALUES
('Dr. Percy', 'Atta', 'percy.atta@gmail.com', '233507149092', 'Computer Engineering'),
('Dr. Jackie', 'Chan', 'jackie.chan@gmail.com', '233507149093', 'Computer Engineering');

-- Create TAAssignments table with reference to 8-digit student_id
CREATE TABLE ta_assignments (
    ta_assignment_id SERIAL PRIMARY KEY,
    ta_id CHAR(8) REFERENCES students(student_id),
    lecturer_id INT REFERENCES lecturers(lecturer_id),
    course_id INT REFERENCES courses(course_id),
    assignment_date DATE
);
-- Insert sample data into TAAssignments table
INSERT INTO ta_assignments (ta_id, lecturer_id, course_id, assignment_date) VALUES
('11384899', 1, 1, '2024-01-25'),
('11036846', 2, 3, '2024-01-25');
-- Create LecturerCourseAssignments table
CREATE TABLE lecturer_course_assignments (
    lecturer_course_assignment_id SERIAL PRIMARY KEY,
    lecturer_id INT REFERENCES lecturers(lecturer_id),
    course_id INT REFERENCES courses(course_id),
    assignment_date DATE
);
-- Insert sample data into LecturerCourseAssignments table
INSERT INTO lecturer_course_assignments (lecturer_id, course_id, assignment_date) VALUES
(1, 1, '2024-01-20'),
(1, 2, '2024-01-20'),
(2, 3, '2024-01-20');




CREATE OR REPLACE FUNCTION calculate_outstanding_fees() RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(json_build_object(
        'student_id', s.student_id,
        'first_name', s.first_name,
        'last_name', s.last_name,
        'total_fees', COALESCE(SUM(f.amount), 0) - 1500
    ))
    INTO result
    FROM students s
    LEFT JOIN fees f ON s.student_id = f.student_id
    GROUP BY s.student_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;