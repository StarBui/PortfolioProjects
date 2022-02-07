-- Standardise Date format 
select SaleDate , convert(date,SaleDate)
from [master].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SaleDate = convert(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)

-- Populate Property Address Data

select *
from [master].[dbo].[NashvilleHousing]
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [master].[dbo].[NashvilleHousing] a
JOIN [master].[dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [master].[dbo].[NashvilleHousing] a
JOIN [master].[dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]

-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from [master].[dbo].[NashvilleHousing]
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from [master].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [master].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [master].[dbo].[NashvilleHousing]


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- DELETE Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [master].[dbo].[NashvilleHousing]
)
Delete 
from RowNumCTE
where row_num >1


--check if duplicates got deleted
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [master].[dbo].[NashvilleHousing]
)
select * 
from RowNumCTE
where row_num >1



-- Delete Ununused Columns

Select *
From [master].[dbo].[NashvilleHousing]

ALTER TABLE [master].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [master].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate