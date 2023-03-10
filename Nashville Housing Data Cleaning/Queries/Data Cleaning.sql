SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Feature Engineering to create standardized date format
   
 

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'

-- Check for Null values in PropertyAddress Column 
SELECT PropertyAddress  
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;
 
-- Update Null Values using ParcelID
/*
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID]
WHERE a.PropertyAddress IS NULL
*/

UPDATE a
	SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID]
	WHERE a.PropertyAddress IS NULL


-- Splitting PropertyAddress
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyAddressSplit nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

UPDATE a
SET a.OwnerAddress =  ISNULL(a.OwnerAddress, b.OwnerAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> B.[UniqueID]
WHERE a.OwnerAddress is null


-- Splitting OwnersAddress
ALTER TABLE NashvilleHousing
ADD 
OwnersAddressSplit nvarchar(255),
OwnersCitySplit nvarchar(255),
OwnersStateSplit nvarchar(255)

Update NashvilleHousing
SET OwnersAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
SET OwnersCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
SET OwnersStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Format SoldAsVacant 
--Change Y and N to Yes and No 

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

UPDATE NashvilleHousing
SET SoldAsVacant = 
			CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				 WHEN SoldAsVacant = 'n' THEN 'NO'
			ELSE SoldAsVacant
			END

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 LegalReference
					 ORDER BY
						UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

 
-- Delete Redundant Columns  

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate


SELECT * FROM PortfolioProject..NashvilleHousing