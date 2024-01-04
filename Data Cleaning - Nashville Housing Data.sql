-- Data Cleaning --



  SELECT * FROM [Projects].[dbo].[NashvilleHousingData ]

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM [Projects].[dbo].[NashvilleHousingData ]
-- Where PropertyAddress is NULL
ORDER By ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Projects].[dbo].[NashvilleHousingData ] a
JOIN [Projects].[dbo].[NashvilleHousingData ] b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Projects].[dbo].[NashvilleHousingData ] a
JOIN [Projects].[dbo].[NashvilleHousingData ] b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Indivudual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Projects].[dbo].[NashvilleHousingData ];


SELECT 
    
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) ) AS Address
FROM [Projects].[dbo].[NashvilleHousingData ];


ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [NashvilleHousingData ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity NVARCHAR(255);

UPDATE [NashvilleHousingData ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) );




SELECT OwnerAddress
FROM [Projects].[dbo].[NashvilleHousingData ];

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Projects].[dbo].[NashvilleHousingData ];


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [NashvilleHousingData ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [NashvilleHousingData ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


ALTER TABLE NashvilleHousingData
ADD OwnerSplitState NVARCHAR(255);

UPDATE [NashvilleHousingData ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [Projects].[dbo].[NashvilleHousingData ]
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM [Projects].[dbo].[NashvilleHousingData ];


UPDATE [NashvilleHousingData ]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY 
                        UniqueID
    ) row_num
FROM [Projects].[dbo].[NashvilleHousingData ]
-- ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress


--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Colums

SELECT *
FROM [Projects].[dbo].[NashvilleHousingData ];


ALTER TABLE [Projects].[dbo].[NashvilleHousingData ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE [Projects].[dbo].[NashvilleHousingData ]
DROP COLUMN SaleDate;