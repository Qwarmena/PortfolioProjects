---CLEANING DATA IN SQL QUERIES

Select *
From PortfolioProject.dbo.NashvilleHousing



---Populate Property Address data where Address is null
---Self join the same table and update the null fields with data

Select aNash.ParcelID, aNash.PropertyAddress, bNash.ParcelID, bNash.PropertyAddress, ISNULL(aNash.PropertyAddress, bNash.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as aNash
Join PortfolioProject.dbo.NashvilleHousing as bNash
	on aNash.ParcelID = bNash.ParcelID
	AND aNash.UniqueID <> bNash.UniqueID
Where aNash.PropertyAddress is null

UPDATE aNash
SET PropertyAddress = ISNULL(aNash.PropertyAddress, bNash.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as aNash
Join PortfolioProject.dbo.NashvilleHousing as bNash
	on aNash.ParcelID = bNash.ParcelID
	AND aNash.UniqueID <> bNash.UniqueID
Where aNash.PropertyAddress is null



---Breaking the address into individual columns
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
    SUBSTRING(PropertyAddress, 1, CASE WHEN CHARINDEX(',', PropertyAddress) > 0 THEN CHARINDEX(',', PropertyAddress) - 1 ELSE LEN(PropertyAddress) END) AS Address1,
    CASE WHEN CHARINDEX(',', PropertyAddress) > 0 THEN 
        SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
    ELSE
        ''
    END AS Address2
FROM PortfolioProject.dbo.NashvilleHousing


--SELECT
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address1
--,	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2
--FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CASE WHEN CHARINDEX(',', PropertyAddress) > 0 THEN CHARINDEX(',', PropertyAddress) - 1 ELSE LEN(PropertyAddress) END)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = CASE WHEN CHARINDEX(',', PropertyAddress) > 0 THEN 
        SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
    ELSE
        ''
    END



---------------------------------------------------------------------------------------------------
---The easiest way is to use PARSENAME
---ParseName only recognises periods so we replace commas with periods
---Also ParseName works in reverse so we use 3,2,1 instead of 1,2,3

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
FROM PortfolioProject.dbo.NashvilleHousing



---Change booleans to YES and NO
Select Distinct(SoldAsVacant), COunt(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 0 THEN 'NO'
	ELSE 'YES'
END
From PortfolioProject.dbo.NashvilleHousing

---The column only accepted boolean values so I need to convert to varchar
ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant Varchar(50)

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'NO'
	ELSE 'YES' END


Select *
FROM PortfolioProject.dbo.NashvilleHousing



---Removing duplicates using CTE
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelID,
				  PropertySplitAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference 
				  ORDER BY UniqueID
	 ) AS RowNumber
FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE RowNumber > 1


DELETE
FROM RowNumCTE
WHERE RowNumber > 1



---Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress


Select *
FROM PortfolioProject.dbo.NashvilleHousing
Order by SaleDate