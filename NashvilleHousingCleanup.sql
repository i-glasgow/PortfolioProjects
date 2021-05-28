
--Adjusting the sales date format--



--In this code we are converting the long format date to show as short format
SELECT SaleDateConverted, CONVERT(DATE, SaleDate) AS UpdatedSalesDate
FROM HousingData..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------

--This Section will fix address info that has NULL Values--



--We will join the table to it's self, then set parameters saying a and b cannot have the same unique id to avoid mismatched data
SELECT a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
	ON a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--now we will update the Null values with the real address information that is stored in b.PropertyAddress 
--and aply it to a.PropertyAddress that is currently storing NULL values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
	ON a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------

--Now to split address info into multiple columns--



--this will split out the address name from the city name
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetName
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityName
FROM HousingData..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SplitAddress NVARCHAR(250);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD SplitCity NVARCHAR(250);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


---------------------------------------------------------------------------------------------------------------------------------------
--to separate the ownder address info the easier way using the PARSENAME
--note to remember that PARSENAME can only separate strings by periods and not commas which is why I am using the replace function--
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM HousingData..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SplitOwnerAddress NVARCHAR(250);

UPDATE NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD SplitOwnerCity NVARCHAR(250);

UPDATE NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD SplitOwnerState NVARCHAR(250);

UPDATE NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------

--To clean the SoldAsVancant column--
Select SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM HousingData..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--To check if only two row names for what we changed
Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


------------------------------------------------------------------
--Cleaning any duplicate values in the table--


WITH ROWNOCTE AS
(
Select *, ROW_NUMBER() 
	OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
		) row_num
FROM HousingData..NashvilleHousing
)
DELETE
FROM RowNoCTE
WHERE row_num > 1

SELECT *
FROM HousingData..NashvilleHousing

ALTER TABLE HousingData..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate