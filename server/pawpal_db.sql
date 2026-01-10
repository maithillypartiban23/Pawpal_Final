-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 10, 2026 at 05:44 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pawpal_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_adoptions`
--

CREATE TABLE `tbl_adoptions` (
  `pet_id` int(5) NOT NULL,
  `adopter_user_id` int(5) NOT NULL,
  `reason` text NOT NULL,
  `requested_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_adoptions`
--

INSERT INTO `tbl_adoptions` (`pet_id`, `adopter_user_id`, `reason`, `requested_at`) VALUES
(18, 3, 'I would like to adopt this pet beacuse I love birds', '2026-01-10 15:39:58.553370'),
(18, 8, 'I wanna adopt this pet', '2026-01-10 22:36:27.611561'),
(23, 2, 'I would like to adopt this pet', '2026-01-10 21:27:33.300325'),
(23, 8, 'I wanna adopt this pet', '2026-01-10 22:38:09.921009');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_donation`
--

CREATE TABLE `tbl_donation` (
  `donation_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `pet_id` int(11) NOT NULL,
  `donation_type` enum('Food','Medical','Money') NOT NULL,
  `amount` decimal(10,2) DEFAULT 0.00,
  `donation_description` text DEFAULT NULL,
  `donation_date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_donation`
--

INSERT INTO `tbl_donation` (`donation_id`, `user_id`, `pet_id`, `donation_type`, `amount`, `donation_description`, `donation_date`) VALUES
(1, 2, 22, 'Medical', 0.00, 'i wanna donate some medication for this pet.', '2026-01-10 17:05:08'),
(2, 2, 22, 'Food', 0.00, 'I would like to provide some food for this pet', '2026-01-10 21:31:50'),
(3, 2, 22, 'Money', 50.00, '', '2026-01-10 21:35:18'),
(4, 8, 25, 'Food', 0.00, 'I have some food for you.', '2026-01-10 22:34:55'),
(5, 8, 22, 'Money', 50.00, '', '2026-01-10 22:40:23');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pets`
--

CREATE TABLE `tbl_pets` (
  `pet_id` int(5) NOT NULL,
  `user_id` int(5) NOT NULL,
  `pet_name` varchar(100) NOT NULL,
  `pet_type` varchar(50) NOT NULL,
  `gender` varchar(6) NOT NULL,
  `age` int(10) NOT NULL,
  `health` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `image_paths` text NOT NULL,
  `lat` varchar(50) NOT NULL,
  `lng` int(11) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pets`
--

INSERT INTO `tbl_pets` (`pet_id`, `user_id`, `pet_name`, `pet_type`, `gender`, `age`, `health`, `category`, `description`, `image_paths`, `lat`, `lng`, `created_at`) VALUES
(18, 2, 'Richy', 'Bird', 'Male', 3, 'Healthy', 'Adoption', 'This bird is available for adoption', '[\"uploads/pet_18_0.png\"]', '5.4001664', 100, '2026-01-10 14:28:35.810811'),
(19, 2, 'Coco', 'Dog', 'Female', 6, 'Healthy', 'Donation', 'Financial support is required for this pet.', '[\"uploads/pet_19_0.png\",\"uploads/pet_19_1.png\",\"uploads/pet_19_2.png\"]', '5.4001664', 100, '2026-01-10 14:29:46.149792'),
(20, 2, 'Goldy', 'Fish', 'Male', 2, 'Healthy', 'Donation', 'This pet needs financial support', '[\"uploads/pet_20_0.png\",\"uploads/pet_20_1.png\"]', '5.4001664', 100, '2026-01-10 14:41:32.290886'),
(21, 3, 'Mongua', 'Cat', 'Female', 4, 'Healthy', 'Help/Rescure', 'This pet needs help', '[\"uploads/pet_21_0.png\",\"uploads/pet_21_1.png\"]', '5.4072755', 100, '2026-01-10 14:43:31.091279'),
(22, 3, 'Parry', 'Bird', 'Female', 2, 'Weak', 'Donation', 'This pet needs money for treatment', '[\"uploads/pet_22_0.png\",\"uploads/pet_22_1.png\",\"uploads/pet_22_2.png\"]', '5.4072755', 100, '2026-01-10 14:45:24.871615'),
(23, 3, 'Rata', 'Rabbit', 'Female', 4, 'Average', 'Adoption', 'This pet is looking for an owner', '[\"uploads/pet_23_0.png\",\"uploads/pet_23_1.png\"]', '5.4001664', 100, '2026-01-10 14:58:35.147504'),
(24, 2, 'Raitu', 'Dog', 'Male', 2, 'Healthy', 'Adoption', 'This pet is looking for an owner to adopt', '[\"uploads/pet_24_0.png\",\"uploads/pet_24_1.png\"]', '5.4001664', 100, '2026-01-10 21:24:48.336730'),
(25, 8, 'Richard', 'Rabbit', 'Female', 2, 'Healthy', 'Donation', 'I want financial help', '[\"uploads/pet_25_0.png\",\"uploads/pet_25_1.png\"]', '5.4001664', 100, '2026-01-10 22:33:39.770415');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(5) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `wallet_balance` decimal(10,2) NOT NULL,
  `reg_date` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`user_id`, `name`, `email`, `password`, `phone`, `wallet_balance`, `reg_date`) VALUES
(1, 'LALA', 'lala@gmail.com', 'e0f0d17d4059eac73af753f35ce1a70a77d3937b', '0198276152', 100.00, '2026-01-10 11:44:11.121427'),
(2, 'Nisa Hannah', 'nisa@gmail.com', 'de2c5be1d220f7bb362e3235aac7c2662df1f639', '0198276153', 0.00, '2026-01-10 12:18:40.528170'),
(3, 'Latari', 'latari@gmail.com', '3facedf1649ccbceb0a72f95e5ff7f9aae56c7b4', '0192738273', 123.99, '2026-01-10 12:50:13.419123'),
(6, 'Maya', 'maya@gmail.com', '1c41e6837126ca0345a446d2a49eef4dc11420b4', '0198273645', 90.00, '2026-01-10 22:16:12.463824'),
(7, 'Rina', 'rina@gmail.com', '61741384864168ded0b4dbcea8d29b3e7c590132', '0198276352', 0.00, '2026-01-10 22:20:57.636446'),
(8, 'Jija Maya', 'jija@gmail.com', '754d55484373a9a4aec74a66edcc8dd44afd31ae', '0192342323', 40.00, '2026-01-10 22:31:12.697272');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_adoptions`
--
ALTER TABLE `tbl_adoptions`
  ADD UNIQUE KEY `pet_id` (`pet_id`,`adopter_user_id`);

--
-- Indexes for table `tbl_donation`
--
ALTER TABLE `tbl_donation`
  ADD PRIMARY KEY (`donation_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pet_id` (`pet_id`);

--
-- Indexes for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  ADD PRIMARY KEY (`pet_id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_donation`
--
ALTER TABLE `tbl_donation`
  MODIFY `donation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  MODIFY `pet_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_donation`
--
ALTER TABLE `tbl_donation`
  ADD CONSTRAINT `tbl_donation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tbl_donation_ibfk_2` FOREIGN KEY (`pet_id`) REFERENCES `tbl_pets` (`pet_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
