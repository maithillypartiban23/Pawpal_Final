PawPal - Pet Adoption & Donation Platform

About The Project
PawPal is a Flutter-based mobile application that connects pet lovers with animals in need. The platform facilitates pet adoption, donations for animal welfare, and rescue operations through an intuitive mobile interface.

PawPal API Reference:

Authentication APIs

1. User Registration
Endpoint: /register_user.php
Method: POST
Purpose: Register a new user account
Parameters:
-name (String) - User's full name (required)
-email (String) - Email address (required, must be unique)
-password (String) - Password (required, min 6 characters)
-phone (String) - Phone number (required)

2. User Login
Endpoint: /login_user.php
Method: POST
Purpose: Authenticate user and return user data
Parameters:
-email (String) - Registered email (required)
-password (String) - Password (required)

Pet Management APIs

3. Get All Pets
Endpoint: /get_my_pets.php
Method: GET
Purpose: Retrieve list of available pets
Parameters:
-searchQuery (String) - Search by pet name (optional)
-filterQuery (String) - Filter by pet type (Dog, Cat, Bird, etc.) (optional)

4. Submit New Pet
Endpoint: /submit_pet.php
Method: POST
Purpose: Create a new pet listing
Parameters:
-userid (String) - Owner's user ID (required)
-name (String) - Pet's name (required)
-age (String) - Pet's age (required)
-type (String) - Pet type (Dog, Cat, Bird, etc.) (required)
-category (String) - Category (Adoption, Donation, Help/Rescue) (required)
-gender (String) - Gender (Male, Female) (required)
-health (String) - Health status (required)
-latitude (String) - Location latitude (required)
-longitude (String) - Location longitude (required)
-description (String) - Detailed description (required, min 10 chars)
-images (JSON) - Base64 encoded images array (required)

5. Request Adoption
Endpoint: /request_adopt.php
Method: POST
Purpose: Submit adoption request for a pet
Parameters:
-pet_id (String) - ID of the pet (required)
-user_id (String) - User ID of requester (required)
-reason (String) - Reason for adoption (required)

Donation APIs

6. Make Donation
Endpoint: /donate_pet.php
Method: POST
Purpose: Submit donation for a pet
Parameters:
-pet_id (String) - ID of the pet (required)
-user_id (String) - Donor's user ID (required)
-donation_type (String) - Type (Money, Food, Medicine) (required)
-amount (String) - Amount in RM (required for Money type)
-description (String) - Description (required for Food/Medicine types)

7. Get User Donations
Endpoint: /get_my_donation.php
Method: GET
Purpose: Retrieve donation history of a user
Parameters:
-userid (String) - User ID (required)

User Profile APIs

8. Update Profile
Endpoint: /update_profile.php
Method: POST
Purpose: Update user profile information
Parameters:
-user_id (String) - User ID (required)
-user_name (String) - New name (optional)
-user_phone (String) - New phone number (optional)
-user_email (String) - New email (optional)
-user_image (String) - Base64 encoded profile image (optional)

9. Get User Details
Endpoint: /getuserdetails.php
Method: GET
Purpose: Get detailed user information
Parameters:
-userid (String) - User ID (required)

Payment API

10. Payment Gateway
Endpoint: /payment.php
Method: GET
Purpose: Redirect to payment page
Parameters:
-email (String) - User's email (required)
-phone (String) - User's phone (required)
-userid (String) - User ID (required)
-name (String) - User's name (required)

amount (String) - Amount in cents (required)


