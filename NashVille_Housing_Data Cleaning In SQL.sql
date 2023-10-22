--Selecting all columns from NashvilleHousing data for quick visual inspection

SELECT * FROM NashvilleHousing;

--Standardize SaleDate by removing the timestamp (2016-02-10 00:00:00:000 --> 2016-02-10)

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SalesDate date;

UPDATE NashvilleHousing
SET SalesDate = CONVERT(date, SaleDate);


--Populate PropertyAddress column to fill in Null fields using ParcelID as reference

SELECT a.[UniqueID ], a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 


--Dividing PropertyAddress into Two different columns (Address, City)

SELECT --Using Substring and CharIndex too Manipulate Address String. This Query allows us to see if the intended results are correct
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, (LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress))) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing --Adding New Column for PropertySplitAddress
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing --Adding New Column for PropertySplitCity
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, (LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress)));


--Breaking OwnerAddress to three different columns (Address, City, State)

SELECT --using PARSENAME To Extract certain parts of an object. PARSENAME only recognises '.' so we have to replace ',' with '.' and it starts reading the string backwards
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS SplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS SplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS SplitCountry
FROM NashvilleHousing

ALTER TABLE NashvilleHousing --Adding New Column for OwnerSplitAddress
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

ALTER TABLE NashvilleHousing --Adding New Column for OwnerSplitCity
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE NashvilleHousing --Adding New Column for OwnerSplitState
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);


--Update SoldAsVacant column to only contain Yes and No
SELECT Distinct SoldAsVacant, COUNT(SoldAsVacant) --to check what are the different entries for the column initially as 'Y' and 'N'
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END AS NewSoldAsVacant
FROM NashvilleHousing

UPDATE NashvilleHousing -- this step will update the SoldAsVacant column based on the Case Statement
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
                   WHEN SoldAsVacant = 'N' THEN 'No'
                   ELSE SoldAsVacant
                   END;


--Remove Duplicate Rows using CTE (Removing of data is usually not done on raw data. Usually done on Views)

WITH RemoveDuplicates AS (SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
                               PropertyAddress,
							   SalePrice,
							   SaleDate,
							   LegalReference
							   ORDER BY UniqueID) AS row_num
FROM NashvilleHousing)
DELETE
FROM RemoveDuplicates
WHERE row_num > 1 --If Row Number is greater than 1 then it is a duplicate Row


--Delete Unused Columns (Once again, Removing of data is usually not done on raw data. Usually done on Views)

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate -- These are the columns which were cleaned previously so we're getting rid of this.




