-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: mysql-sirh.alwaysdata.net
-- Generation Time: Jul 01, 2026 at 05:49 PM
-- Server version: 10.11.18-MariaDB
-- PHP Version: 8.4.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sirh_carnet`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_informations`
--

CREATE TABLE `admin_informations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `eleve_id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL,
  `titre` varchar(255) DEFAULT NULL,
  `contenu` text NOT NULL,
  `montant` decimal(10,2) DEFAULT NULL,
  `montant_paye` decimal(10,2) DEFAULT NULL,
  `montant_restant` decimal(10,2) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_informations`
--

INSERT INTO `admin_informations` (`id`, `eleve_id`, `type`, `titre`, `contenu`, `montant`, `montant_paye`, `montant_restant`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 1, 'convocation', 'Information Administration', 'Bonjour, vous êtes convoqué(e) à la direction de l\'établissement concernant votre enfant. Merci de vous présenter dès réception de ce message.', NULL, NULL, NULL, 0, '2026-06-06 08:43:59', '2026-06-06 08:43:59'),
(2, 2, 'convocation', 'Information Administration', 'Bonjour, vous êtes convoqué(e) à la direction de l\'établissement concernant votre enfant. Merci de vous présenter dès réception de ce message.', NULL, NULL, NULL, 0, '2026-06-06 08:43:59', '2026-06-06 08:43:59'),
(3, 3, 'convocation', 'Information Administration', 'Bonjour, vous êtes convoqué(e) à la direction de l\'établissement concernant votre enfant. Merci de vous présenter dès réception de ce message.', NULL, NULL, NULL, 0, '2026-06-06 08:43:59', '2026-06-06 08:43:59'),
(4, 4, 'convocation', 'Information Administration', 'Bonjour, vous êtes convoqué(e) à la direction de l\'établissement concernant votre enfant. Merci de vous présenter dès réception de ce message.', NULL, NULL, NULL, 0, '2026-06-06 08:43:59', '2026-06-06 08:43:59'),
(5, 5, 'convocation', 'Information Administration', 'Bonjour, vous êtes convoqué(e) à la direction de l\'établissement concernant votre enfant. Merci de vous présenter dès réception de ce message.', NULL, NULL, NULL, 0, '2026-06-06 08:43:59', '2026-06-06 08:43:59');

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `enseignant_id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `eleve_id` bigint(20) UNSIGNED DEFAULT NULL,
  `objet` varchar(255) DEFAULT NULL,
  `date_heure` datetime NOT NULL,
  `new_proposed_date` datetime DEFAULT NULL,
  `type` enum('physique','video') NOT NULL DEFAULT 'physique',
  `mode` enum('presentiel','vocal','video') NOT NULL DEFAULT 'presentiel',
  `lien_video` varchar(255) DEFAULT NULL,
  `statut` enum('en_attente','accepte','refuse','reporte') NOT NULL DEFAULT 'en_attente',
  `motif` text DEFAULT NULL,
  `report_reason` text DEFAULT NULL,
  `requester` enum('parent','enseignant') NOT NULL DEFAULT 'parent',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendances`
--

CREATE TABLE `attendances` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `eleve_id` bigint(20) UNSIGNED NOT NULL,
  `classe_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('present','absent','late') NOT NULL DEFAULT 'present',
  `heure_arrivee` time DEFAULT NULL,
  `date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `attendances`
--

INSERT INTO `attendances` (`id`, `eleve_id`, `classe_id`, `status`, `heure_arrivee`, `date`, `created_at`, `updated_at`) VALUES
(3, 1, 1, 'late', NULL, '2026-06-05', '2026-06-05 10:55:03', '2026-06-05 10:55:03'),
(10, 1, 1, 'absent', NULL, '2026-06-06', '2026-06-06 08:52:48', '2026-06-06 08:59:50'),
(11, 2, 1, 'present', NULL, '2026-06-06', '2026-06-06 08:52:48', '2026-06-06 08:52:48'),
(12, 3, 1, 'present', NULL, '2026-06-06', '2026-06-06 08:52:48', '2026-06-06 08:52:48'),
(13, 4, 1, 'present', NULL, '2026-06-06', '2026-06-06 08:52:48', '2026-06-06 08:52:48'),
(14, 5, 1, 'absent', NULL, '2026-06-06', '2026-06-06 08:52:48', '2026-06-06 08:52:48');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `calls`
--

CREATE TABLE `calls` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `caller_id` bigint(20) UNSIGNED NOT NULL,
  `caller_type` varchar(255) NOT NULL,
  `receiver_id` bigint(20) UNSIGNED NOT NULL,
  `receiver_type` varchar(255) NOT NULL,
  `type` enum('audio','video') NOT NULL DEFAULT 'audio',
  `status` enum('ringing','accepted','rejected','missed','ended') NOT NULL DEFAULT 'ringing',
  `started_at` timestamp NULL DEFAULT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `call_signaling`
--

CREATE TABLE `call_signaling` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `call_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('offer','answer','ice_candidate') NOT NULL,
  `sdp` text DEFAULT NULL,
  `sdp_mid` varchar(255) DEFAULT NULL,
  `sdp_m_line_index` int(11) DEFAULT NULL,
  `candidate` text DEFAULT NULL,
  `processed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `code` varchar(10) DEFAULT NULL,
  `ecole_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `prof_principal_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`id`, `nom`, `code`, `ecole_id`, `created_at`, `updated_at`, `prof_principal_id`) VALUES
(1, 'Terminale C', 'TERMI', 1, '2026-06-05 10:08:23', '2026-06-05 10:08:38', 1);

-- --------------------------------------------------------

--
-- Table structure for table `classe_enseignant`
--

CREATE TABLE `classe_enseignant` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `classe_id` bigint(20) UNSIGNED NOT NULL,
  `enseignant_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ecole_id` bigint(20) UNSIGNED DEFAULT NULL,
  `enseignant_id` bigint(20) UNSIGNED DEFAULT NULL,
  `parent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `status` enum('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `conversations`
--

INSERT INTO `conversations` (`id`, `ecole_id`, `enseignant_id`, `parent_id`, `subject`, `status`, `created_at`, `updated_at`) VALUES
(1, NULL, 1, 1, 'Discussion avec dgall Nguema', 'accepted', '2026-06-05 13:39:47', '2026-06-05 13:40:00');

-- --------------------------------------------------------

--
-- Table structure for table `device_tokens`
--

CREATE TABLE `device_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `token` varchar(255) NOT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `devoirs`
--

CREATE TABLE `devoirs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `classe_id` bigint(20) UNSIGNED NOT NULL,
  `enseignant_id` bigint(20) UNSIGNED DEFAULT NULL,
  `matiere` varchar(255) NOT NULL,
  `type` enum('maison','classe','exercice') NOT NULL DEFAULT 'maison',
  `titre` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `date_remise` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `devoirs`
--

INSERT INTO `devoirs` (`id`, `classe_id`, `enseignant_id`, `matiere`, `type`, `titre`, `description`, `date_remise`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Mathématiques', 'classe', 'fonctionnement linéaire', 'pas de calculatrice', '2026-06-08', '2026-06-05 10:18:34', '2026-06-05 10:18:34');

-- --------------------------------------------------------

--
-- Table structure for table `devoir_eleve`
--

CREATE TABLE `devoir_eleve` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `devoir_id` bigint(20) UNSIGNED NOT NULL,
  `eleve_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `devoir_eleve`
--

INSERT INTO `devoir_eleve` (`id`, `devoir_id`, `eleve_id`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-06-05 10:18:34', '2026-06-05 10:18:34');

-- --------------------------------------------------------

--
-- Table structure for table `ecoles`
--

CREATE TABLE `ecoles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `code` varchar(10) NOT NULL,
  `annee_scolaire` varchar(255) NOT NULL DEFAULT '2025-2026',
  `nb_classes` int(11) NOT NULL DEFAULT 0,
  `nb_profs` int(11) NOT NULL DEFAULT 0,
  `nb_eleves` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ecoles`
--

INSERT INTO `ecoles` (`id`, `nom`, `code`, `annee_scolaire`, `nb_classes`, `nb_profs`, `nb_eleves`, `created_at`, `updated_at`) VALUES
(1, 'Lycée Notre dame quaben', 'LYNDQ', '2026-2027', 6, 20, 150, '2026-06-05 08:58:53', '2026-06-05 08:58:53');

-- --------------------------------------------------------

--
-- Table structure for table `eleves`
--

CREATE TABLE `eleves` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `matricule` varchar(255) NOT NULL,
  `classe_id` bigint(20) UNSIGNED NOT NULL,
  `code_secret` varchar(255) DEFAULT NULL,
  `qr_code` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `lieu_naissance` varchar(255) DEFAULT NULL,
  `statut` varchar(255) DEFAULT 'actif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eleves`
--

INSERT INTO `eleves` (`id`, `nom`, `prenom`, `matricule`, `classe_id`, `code_secret`, `qr_code`, `created_at`, `updated_at`, `photo`, `date_naissance`, `lieu_naissance`, `statut`) VALUES
(1, 'Nguema', 'Yannick', 'MAT-6A22BC9C459E9', 1, 'LYNDQ-TERMI-7584', NULL, '2026-06-05 10:10:04', '2026-06-05 10:10:04', 'photos/eleves/irvg9Tsu2PIBIuCTBAdwuQadHN8m8CAwvhBEpBfh.jpg', '2004-02-05', 'Libreville', 'actif'),
(2, 'Obone', 'Verone', 'MAT-6A23E0FD96886', 1, 'LYNDQ-TERMI-8897', NULL, '2026-06-06 06:57:33', '2026-06-06 06:57:33', 'photos/eleves/oh3C9iWjpTlGvni2dJGexoOr0aG7qPUNyqym0FvR.jpg', '2007-06-06', 'Libreville', 'actif'),
(3, 'Loumbet', 'jessy', 'MAT-6A23E154D1B64', 1, 'LYNDQ-TERMI-6286', NULL, '2026-06-06 06:59:00', '2026-06-06 06:59:00', 'photos/eleves/XKks1Zn1h19DWag7bDj2ayTPoBPso5Cn4oCmA350.jpg', '2001-05-30', 'Libreville', 'actif'),
(4, 'ngou', 'joann', 'MAT-6A23E18F75566', 1, 'LYNDQ-TERMI-4145', NULL, '2026-06-06 06:59:59', '2026-06-06 06:59:59', 'photos/eleves/dzqJRwguZi36ZnxSSglVZ8ykE8Ls1LLwVJH6ZIer.jpg', '2005-02-06', 'oyem', 'actif'),
(5, 'mvou', 'vanille', 'MAT-6A23E1C3CBADF', 1, 'LYNDQ-TERMI-8065', NULL, '2026-06-06 07:00:51', '2026-06-06 07:00:51', 'photos/eleves/O3MLWfU85RHue4Fiqw5iOouHPHS0MTlnvduwT02j.jpg', '2002-07-11', 'LLIBREVILLE', 'actif');

-- --------------------------------------------------------

--
-- Table structure for table `eleve_parents`
--

CREATE TABLE `eleve_parents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `eleve_id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `relation` varchar(255) NOT NULL DEFAULT 'Parent',
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eleve_parents`
--

INSERT INTO `eleve_parents` (`id`, `eleve_id`, `parent_id`, `relation`, `is_verified`, `created_at`, `updated_at`) VALUES
(4, 1, 2, 'Père', 0, '2026-06-15 11:32:08', '2026-06-15 11:32:08'),
(5, 2, 3, 'Mère', 0, '2026-06-15 11:34:58', '2026-06-15 11:34:58'),
(6, 2, 2, 'Tuteur', 0, '2026-06-29 07:47:49', '2026-06-29 07:47:49');

-- --------------------------------------------------------

--
-- Table structure for table `enseignants`
--

CREATE TABLE `enseignants` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `matiere` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `ecole_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `enseignants`
--

INSERT INTO `enseignants` (`id`, `prenom`, `nom`, `matiere`, `email`, `fcm_token`, `telephone`, `password`, `ecole_id`, `created_at`, `updated_at`) VALUES
(1, 'Michel', 'Obame', 'Mathématiques', 'Michel@gmail.com', 'cUB7mgthRmSZ3lAzT6OZE8:APA91bGClAPL2wEq4iUAGPLvBfnZRMTucqkMt3mn5JZy30Y6ene_Wxa-23WzN5-4nUQ7DxBZIiZXN891zBuUxNmpWOUtzGr7w23cHHAYNxiDGLeAsWSxZec', '065546609', '$2y$12$lir1rZ/FEqbmyj0X7ZCkiugiF7YmXOOeO0ACvuwdnIaKDC1nGAk1S', NULL, '2026-06-05 10:08:09', '2026-06-18 16:04:26'),
(2, 'servais', 'mba', 'Philosophie', 'mba@gmail.com', NULL, '+24165660978', '$2y$12$VhmCynFoqc9oug8idrfEXudx5eU4W/ghYgoyjF5TnKSydf5.Mbv6u', NULL, '2026-06-06 07:08:52', '2026-06-06 07:08:52'),
(3, 'Odou', 'Charles', 'Physique-Chimie', 'Edou@gmail.com', NULL, '+24178963233', '$2y$12$lZ/xAXFQDMrPjIKigR5m5OUZ3FgDGndR.9gng3H7okINfi0BqPsla', NULL, '2026-06-06 07:10:06', '2026-06-06 07:10:06'),
(4, 'vivian', 'Eyann', 'Français', 'eyan@gmail.com', NULL, '+24165866877', '$2y$12$iJJHttN3fZ1ntoI/pdjdUupFkrzgv1g..I.UTlHZD3aFPhzNc30q.', NULL, '2026-06-06 07:10:46', '2026-06-06 07:10:46');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `incidents`
--

CREATE TABLE `incidents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `eleve_id` bigint(20) UNSIGNED NOT NULL,
  `enseignant_id` bigint(20) UNSIGNED NOT NULL,
  `classe_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` enum('desordre','bavardage','bagarre','injure','retenu','autre') NOT NULL,
  `description` text DEFAULT NULL,
  `date` date NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `incidents`
--

INSERT INTO `incidents` (`id`, `eleve_id`, `enseignant_id`, `classe_id`, `type`, `description`, `date`, `is_read`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'bavardage', 'bagarré avec collègue clqse', '2026-06-05', 1, '2026-06-05 10:17:42', '2026-06-05 10:17:00', '2026-06-05 10:17:42'),
(2, 1, 1, 1, 'injure', 'ton cut', '2026-06-05', 1, '2026-06-05 10:51:58', '2026-06-05 10:48:10', '2026-06-05 10:51:58'),
(3, 1, 1, 1, 'bagarre', 'ddd', '2026-06-05', 0, NULL, '2026-06-05 10:52:12', '2026-06-05 10:52:12'),
(4, 1, 1, 1, 'retenu', 'problème', '2026-06-05', 1, '2026-06-05 10:55:50', '2026-06-05 10:54:49', '2026-06-05 10:55:50');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `sender_type` enum('enseignant','parent','admin') NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `conversation_id`, `sender_type`, `sender_id`, `content`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 1, 'enseignant', 1, 'bjr', 1, '2026-06-05 13:39:47', '2026-06-05 13:39:57'),
(2, 1, 'parent', 1, 'bjr', 1, '2026-06-05 13:40:08', '2026-06-06 09:13:24');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_05_24_050001_create_users_table', 1),
(2, '2026_05_24_050002_create_cache_table', 1),
(3, '2026_05_24_0500035_create_ecoles_table', 1),
(4, '2026_05_24_050003_create_jobs_table', 1),
(5, '2026_05_24_050004_create_classes_table', 1),
(6, '2026_05_24_050005_create_parent_users_table', 1),
(7, '2026_05_24_050006_create_eleves_table', 1),
(8, '2026_05_24_050007_create_eleve_parents_table', 1),
(9, '2026_05_24_050008_create_enseignants_table', 1),
(10, '2026_05_24_231017_add_prof_principal_id_to_classes_table', 1),
(11, '2026_05_26_093458_create_device_tokens_table', 1),
(12, '2026_05_26_093956_create_attendances_table', 1),
(13, '2026_05_26_100938_create_conversations_table', 1),
(14, '2026_05_26_100939_create_messages_table', 1),
(15, '2026_05_26_111527_add_fcm_token_to_users_tables', 1),
(16, '2026_05_26_170701_create_devoirs_table', 1),
(17, '2026_05_26_172900_create_appointments_table', 1),
(18, '2026_05_28_105744_add_status_and_subject_to_conversations_table', 1),
(19, '2026_05_28_125014_add_statut_to_eleves_table', 1),
(20, '2026_05_29_043002_create_admin_informations_table', 1),
(21, '2026_05_29_123027_add_finance_fields_to_admin_informations_table', 1),
(22, '2026_05_30_124352_add_requester_to_appointments_table', 1),
(23, '2026_05_31_144524_create_notifications_table', 1),
(24, '2026_06_02_170000_create_incidents_table', 1),
(25, '2026_06_02_220000_add_type_to_devoirs_table', 1),
(26, '2026_06_02_220001_create_devoir_eleve_table', 1),
(27, '2026_06_03_110000_add_report_fields_to_appointments', 1),
(28, '2026_06_03_120000_create_calls_table', 1),
(29, '2026_06_03_121000_create_reports_table', 1),
(30, '2026_06_03_122000_create_call_signaling_table', 1),
(31, '2026_06_05_100000_add_heure_arrivee_to_attendances', 1),
(32, '2026_06_06_085903_create_classe_enseignant_table', 2),
(33, '2026_06_18_160446_make_parent_id_nullable_in_conversations_table', 3),
(34, '2026_07_01_000000_add_is_verified_to_eleve_parents', 4);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_type` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_type`, `user_id`, `type`, `title`, `message`, `data`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 'parent', 1, 'new_homework', 'Devoir de classe - Mathématiques', 'fonctionnement linéaire\nÀ rendre pour le 08/06/2026', '{\"devoir_id\":\"1\",\"type\":\"new_homework\",\"homework_type\":\"classe\",\"classe_id\":\"1\",\"matiere\":\"Math\\u00e9matiques\",\"titre\":\"fonctionnement lin\\u00e9aire\",\"date_remise\":\"2026-06-08\",\"eleve_id\":\"1\",\"eleve_nom\":\"Yannick Nguema\"}', 0, '2026-06-05 10:18:34', '2026-06-05 10:18:34'),
(2, 'parent', 1, 'appointment_request', '📅 Nouveau rendez-vous proposé', 'Michel Obame propose un rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"2\",\"type\":\"appointment_request\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06T09:00:00.000\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"eleve_nom\":\"Yannick Nguema\",\"statut\":\"en_attente\"}', 0, '2026-06-05 11:59:54', '2026-06-05 11:59:54'),
(3, 'parent', 1, 'appointment_request', '📅 Nouveau rendez-vous proposé', 'Michel Obame propose un rendez-vous pour le 06/06/2026 à 03:00', '{\"appointment_id\":\"3\",\"type\":\"appointment_request\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06T03:00:00.000\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"eleve_nom\":\"Yannick Nguema\",\"statut\":\"en_attente\"}', 0, '2026-06-05 12:01:02', '2026-06-05 12:01:02'),
(4, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 22/06/2026 à 08:00', '{\"appointment_id\":\"1\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"tyh\",\"date_heure\":\"2026-06-22 08:00:00\",\"mode\":\"video\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 12:05:46', '2026-06-05 12:05:46'),
(5, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"5\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:31:41', '2026-06-05 13:31:41'),
(6, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"4\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:31:44', '2026-06-05 13:31:44'),
(7, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"6\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:31:50', '2026-06-05 13:31:50'),
(8, 'parent', 1, 'appointment_request', '📅 Nouveau rendez-vous proposé', 'Michel Obame propose un rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"7\",\"type\":\"appointment_request\",\"objet\":\"Demande de rendez-vous en vid\\u00e9o\",\"date_heure\":\"2026-06-06T09:00:00.000\",\"mode\":\"video\",\"enseignant_nom\":\"Michel Obame\",\"eleve_nom\":\"Yannick Nguema\",\"statut\":\"en_attente\"}', 0, '2026-06-05 13:32:08', '2026-06-05 13:32:08'),
(9, 'enseignant', 1, 'appointment_request', '📅 Nouvelle demande de rendez-vous', 'dgall Nguema demande un rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"8\",\"type\":\"appointment_request\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06T09:00:00.000\",\"mode\":\"presentiel\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null,\"statut\":\"en_attente\"}', 0, '2026-06-05 13:36:28', '2026-06-05 13:36:28'),
(10, 'enseignant', 1, 'appointment_request', '📅 Nouvelle demande de rendez-vous', 'dgall Nguema demande un rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"9\",\"type\":\"appointment_request\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06T09:00:00.000\",\"mode\":\"presentiel\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null,\"statut\":\"en_attente\"}', 0, '2026-06-05 13:36:57', '2026-06-05 13:36:57'),
(11, 'enseignant', 1, 'appointment_request', '📅 Nouvelle demande de rendez-vous', 'dgall Nguema demande un rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"10\",\"type\":\"appointment_request\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06T09:00:00.000\",\"mode\":\"presentiel\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null,\"statut\":\"en_attente\"}', 0, '2026-06-05 13:37:13', '2026-06-05 13:37:13'),
(12, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"10\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:37:32', '2026-06-05 13:37:32'),
(13, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"9\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:37:36', '2026-06-05 13:37:36'),
(14, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"8\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:37:39', '2026-06-05 13:37:39'),
(15, 'parent', 1, 'appointment_accepted', '✅ Rendez-vous accepté', 'Michel Obame a accepté votre demande de rendez-vous pour le 06/06/2026 à 09:00', '{\"appointment_id\":\"8\",\"type\":\"appointment_accepted\",\"statut\":\"accepte\",\"objet\":\"Demande de rendez-vous en pr\\u00e9sentiel\",\"date_heure\":\"2026-06-06 09:00:00\",\"mode\":\"presentiel\",\"enseignant_nom\":\"Michel Obame\",\"parent_nom\":\"dgall Nguema\",\"eleve_nom\":null}', 0, '2026-06-05 13:37:41', '2026-06-05 13:37:41'),
(16, 'parent', 1, 'new_conversation_request', '💬 Nouveau message de Michel Obame', 'bjr', '{\"type\":\"new_conversation_request\",\"conversation_id\":\"1\",\"enseignant_id\":\"1\",\"enseignant_nom\":\"Michel Obame\",\"subject\":\"Discussion avec dgall Nguema\",\"status\":\"pending\",\"action\":\"validate_conversation\"}', 0, '2026-06-05 13:39:47', '2026-06-05 13:39:47'),
(17, 'parent', 1, 'chat_accepted', '✅ Liaison acceptée', 'Vous pouvez maintenant discuter avec Michel Obame.', '{\"type\":\"chat_accepted\",\"conversation_id\":\"1\",\"status\":\"accepted\",\"action\":\"open_chat\"}', 0, '2026-06-05 13:40:00', '2026-06-05 13:40:00'),
(18, 'enseignant', 1, 'parent_message', 'Nouveau message de Un parent', 'bjr', '{\"conversation_id\":\"1\",\"type\":\"parent_message\"}', 0, '2026-06-05 13:40:08', '2026-06-05 13:40:08'),
(19, 'parent', 1, 'admin_info', 'Nouveau message de l\'Administration', 'Bonjour, vous êtes convoqué(e) à la direction de l\'établissement concernant votre enfant. Merci ...', '{\"type\":\"admin_info\",\"eleve_id\":\"1\",\"admin_info_id\":\"1\"}', 0, '2026-06-06 08:43:59', '2026-06-06 08:43:59');

-- --------------------------------------------------------

--
-- Table structure for table `parent_users`
--

CREATE TABLE `parent_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `parent_users`
--

INSERT INTO `parent_users` (`id`, `nom`, `prenom`, `email`, `password`, `telephone`, `created_at`, `updated_at`, `fcm_token`) VALUES
(2, 'Nguema', 'dgall', 'dgall@gmail.com', '$2y$12$zEY1tE5Ghlq5KfQFFQaf1uriNQZBHgsIzC4lPH481BoibpDI6RTcG', '+24165546609', '2026-06-15 11:32:08', '2026-07-01 13:22:37', 'e106U936SZydFR47lMDxUZ:APA91bGbOyOACxLiAYaeQvDa4ToE9ffi7uZh96aojCfW3RBmJoc6nQoo9cO6U_lko7CtREukunDCilO5b4sJP7csrAXSP7ZBByDRm0ivxmVGKmeddzsyy0A'),
(3, 'Obone', 'ada', 'Obone@gmail.com', '$2y$12$myQqKqruhgmHLkjCjVOjQOqDs9wiF4enkgK.01duSdqjvkiBcmjgm', '+24156699778', '2026-06-15 11:34:58', '2026-06-15 11:34:58', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `reporter_id` bigint(20) UNSIGNED NOT NULL,
  `reporter_type` varchar(255) NOT NULL,
  `reported_id` bigint(20) UNSIGNED NOT NULL,
  `reported_type` varchar(255) NOT NULL,
  `reason` enum('harassment','inappropriate_content','spam','fake_account','other') NOT NULL,
  `description` text DEFAULT NULL,
  `evidence` text DEFAULT NULL,
  `status` enum('pending','in_review','resolved','rejected') NOT NULL DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_informations`
--
ALTER TABLE `admin_informations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_informations_eleve_id_foreign` (`eleve_id`);

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `appointments_enseignant_id_foreign` (`enseignant_id`),
  ADD KEY `appointments_parent_id_foreign` (`parent_id`),
  ADD KEY `appointments_eleve_id_foreign` (`eleve_id`);

--
-- Indexes for table `attendances`
--
ALTER TABLE `attendances`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `calls`
--
ALTER TABLE `calls`
  ADD PRIMARY KEY (`id`),
  ADD KEY `calls_conversation_id_foreign` (`conversation_id`);

--
-- Indexes for table `call_signaling`
--
ALTER TABLE `call_signaling`
  ADD PRIMARY KEY (`id`),
  ADD KEY `call_signaling_call_id_foreign` (`call_id`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `classes_ecole_id_foreign` (`ecole_id`);

--
-- Indexes for table `classe_enseignant`
--
ALTER TABLE `classe_enseignant`
  ADD PRIMARY KEY (`id`),
  ADD KEY `classe_enseignant_classe_id_foreign` (`classe_id`),
  ADD KEY `classe_enseignant_enseignant_id_foreign` (`enseignant_id`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `conv_unique` (`ecole_id`,`enseignant_id`,`parent_id`);

--
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `device_tokens_token_unique` (`token`);

--
-- Indexes for table `devoirs`
--
ALTER TABLE `devoirs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `devoirs_classe_id_foreign` (`classe_id`),
  ADD KEY `devoirs_enseignant_id_foreign` (`enseignant_id`);

--
-- Indexes for table `devoir_eleve`
--
ALTER TABLE `devoir_eleve`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `devoir_eleve_devoir_id_eleve_id_unique` (`devoir_id`,`eleve_id`),
  ADD KEY `devoir_eleve_eleve_id_foreign` (`eleve_id`);

--
-- Indexes for table `ecoles`
--
ALTER TABLE `ecoles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ecoles_code_unique` (`code`);

--
-- Indexes for table `eleves`
--
ALTER TABLE `eleves`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `eleves_matricule_unique` (`matricule`),
  ADD UNIQUE KEY `eleves_code_secret_unique` (`code_secret`),
  ADD KEY `eleves_classe_id_foreign` (`classe_id`);

--
-- Indexes for table `eleve_parents`
--
ALTER TABLE `eleve_parents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `eleve_parents_eleve_id_parent_id_unique` (`eleve_id`,`parent_id`),
  ADD KEY `eleve_parents_parent_id_foreign` (`parent_id`);

--
-- Indexes for table `enseignants`
--
ALTER TABLE `enseignants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `enseignants_ecole_id_foreign` (`ecole_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `incidents`
--
ALTER TABLE `incidents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `incidents_enseignant_id_foreign` (`enseignant_id`),
  ADD KEY `incidents_classe_id_foreign` (`classe_id`),
  ADD KEY `incidents_eleve_id_date_index` (`eleve_id`,`date`),
  ADD KEY `incidents_is_read_index` (`is_read`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `messages_conversation_id_foreign` (`conversation_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `parent_users`
--
ALTER TABLE `parent_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `parent_users_email_unique` (`email`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reports_conversation_id_foreign` (`conversation_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_informations`
--
ALTER TABLE `admin_informations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `attendances`
--
ALTER TABLE `attendances`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `calls`
--
ALTER TABLE `calls`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `call_signaling`
--
ALTER TABLE `call_signaling`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `classes`
--
ALTER TABLE `classes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `classe_enseignant`
--
ALTER TABLE `classe_enseignant`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `devoirs`
--
ALTER TABLE `devoirs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `devoir_eleve`
--
ALTER TABLE `devoir_eleve`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ecoles`
--
ALTER TABLE `ecoles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `eleves`
--
ALTER TABLE `eleves`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `eleve_parents`
--
ALTER TABLE `eleve_parents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `enseignants`
--
ALTER TABLE `enseignants`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `incidents`
--
ALTER TABLE `incidents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `parent_users`
--
ALTER TABLE `parent_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_informations`
--
ALTER TABLE `admin_informations`
  ADD CONSTRAINT `admin_informations_eleve_id_foreign` FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_eleve_id_foreign` FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_enseignant_id_foreign` FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `parent_users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `calls`
--
ALTER TABLE `calls`
  ADD CONSTRAINT `calls_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `call_signaling`
--
ALTER TABLE `call_signaling`
  ADD CONSTRAINT `call_signaling_call_id_foreign` FOREIGN KEY (`call_id`) REFERENCES `calls` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `classes_ecole_id_foreign` FOREIGN KEY (`ecole_id`) REFERENCES `ecoles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `classe_enseignant`
--
ALTER TABLE `classe_enseignant`
  ADD CONSTRAINT `classe_enseignant_classe_id_foreign` FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `classe_enseignant_enseignant_id_foreign` FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `devoirs`
--
ALTER TABLE `devoirs`
  ADD CONSTRAINT `devoirs_classe_id_foreign` FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `devoirs_enseignant_id_foreign` FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `devoir_eleve`
--
ALTER TABLE `devoir_eleve`
  ADD CONSTRAINT `devoir_eleve_devoir_id_foreign` FOREIGN KEY (`devoir_id`) REFERENCES `devoirs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `devoir_eleve_eleve_id_foreign` FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `eleves`
--
ALTER TABLE `eleves`
  ADD CONSTRAINT `eleves_classe_id_foreign` FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `eleve_parents`
--
ALTER TABLE `eleve_parents`
  ADD CONSTRAINT `eleve_parents_eleve_id_foreign` FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eleve_parents_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `parent_users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `enseignants`
--
ALTER TABLE `enseignants`
  ADD CONSTRAINT `enseignants_ecole_id_foreign` FOREIGN KEY (`ecole_id`) REFERENCES `ecoles` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `incidents`
--
ALTER TABLE `incidents`
  ADD CONSTRAINT `incidents_classe_id_foreign` FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `incidents_eleve_id_foreign` FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `incidents_enseignant_id_foreign` FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
