
-----------------------Cleaning the Data

SELECT * 
FROM portfolioproject..NashvilleHousing



------------------------updating New Date format


ALTER TABLE portfolioproject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE portfolioproject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




---------------------- Populate Property Address Data


Select *
FROM portfolioproject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioproject..NashvilleHousing a
JOIN portfolioproject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioproject..NashvilleHousing a
JOIN portfolioproject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL



---------------------------Breaking Address into (Address, City, State)



Select PropertyAddress
FROM portfolioproject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM portfolioproject..NashvilleHousing


ALTER TABLE portfolioproject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE portfolioproject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE portfolioproject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE portfolioproject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT * 
FROM portfolioproject..NashvilleHousing



------------------------OwnerAddress Split


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM portfolioproject..NashvilleHousing


ALTER TABLE portfolioproject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE portfolioproject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE portfolioproject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE portfolioproject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE portfolioproject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE portfolioproject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM portfolioproject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2




SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM portfolioproject..NashvilleHousing


UPDATE portfolioproject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END




-------------------------Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					) row_num
FROM portfolioproject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *  
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




---------------------------- Delete UnusedData
-----------------------------Dont' do it to Raw Data


ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress,TaxDistrict, SaleDate