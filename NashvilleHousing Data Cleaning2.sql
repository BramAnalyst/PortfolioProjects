
/*

Cleaning Data in SQL 

*/

----------------------------------------------------------------------------------------------------------------------------------------------------------



-- Standardize Date Format



SELECT 
	sale_date_converted,
	CONVERT(date, SaleDate) AS date
From 
	PortfolioProject.dbo.NashvilleHousing


ALTER TABLE
	NashvilleHousing
ADD 
	sale_date_converted Date;


UPDATE
	NashvilleHousing
SET 
	sale_date_converted = CONVERT(Date, SaleDate)	


----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Populate Missing Property Address data


SELECT 
	*
From 
	PortfolioProject.dbo.NashvilleHousing
WHERE 
	PropertyAddress IS NULL



-- Select Property Addresses where NULL and the same Parcel ID is used elsewhere



SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProject.dbo.NashvilleHousing AS a
JOIN
	PortfolioProject.dbo.NashvilleHousing AS b
ON
	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL 


-- Update Missing Property Addresses in Table


Update
	a
SET 
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
		PortfolioProject.dbo.NashvilleHousing AS a
	JOIN
		PortfolioProject.dbo.NashvilleHousing AS b
	ON
		a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL 



----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT 
	PropertyAddress 
FROM
	PortfolioProject.dbo.NashvilleHousing



-- Select only the Address from Property Address separated by Delimiter 



SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM
	PortfolioProject.dbo.NashvilleHousing



-- Add New Columns for Address and City and Populate with respective data



ALTER TABLE 
	NashvilleHousing
ADD
	property_split_address Nvarchar(255);


UPDATE 
	NashvilleHousing
SET 
	property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)





ALTER TABLE 
	NashvilleHousing
ADD 
	property_split_city Nvarchar(255);


UPDATE 
	NashvilleHousing
SET 
	property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 2, LEN(PropertyAddress))



-- Separate Owner Address Into City, State, and Address using PARSENAME



SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM
	PortfolioProject.dbo.NashvilleHousing




-- Add New Columns for Owner Address, City, State and Populate with respective data



ALTER TABLE 
	NashvilleHousing
ADD
	owner_split_address Nvarchar(255);


UPDATE 
	NashvilleHousing
SET 
	owner_split_address = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3))






ALTER TABLE 
	NashvilleHousing
ADD
	owner_split_city Nvarchar(255);


UPDATE 
	NashvilleHousing
SET 
	owner_split_city = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))






ALTER TABLE 
	NashvilleHousing
ADD
	owner_split_state Nvarchar(255);


UPDATE 
	NashvilleHousing
SET 
	owner_split_state = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))



----------------------------------------------------------------------------------------------------------------------------------------------------------



-- Finding which method of response is most used in SoldAsVacant Field



SELECT 
	SoldAsVacant,
	COUNT(1) AS num_of_respones
FROM 
	PortfolioProject.dbo.NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	num_of_respones DESC



-- Change "Y" and "N" to "Yes" and "No" in "Sold as Vacant" field



SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS sold_as_vacant
FROM 
	PortfolioProject.DBO.NashvilleHousing



-- Update SoldAsVacant Column



UPDATE
	NashvilleHousing
SET 
	SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
END



----------------------------------------------------------------------------------------------------------------------------------------------------------



-- Remove Duplicates



WITH duplicates
	AS
		(
		SELECT
			*,
			ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY 
							UniqueID
							) row_num
		FROM PortfolioProject.dbo.NashvilleHousing
		)
SELECT 
	*
FROM 
	duplicates
WHERE 
	row_num > 1
ORDER BY 
	PropertyAddress



----------------------------------------------------------------------------------------------------------------------------------------------------------






