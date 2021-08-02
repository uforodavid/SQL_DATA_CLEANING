/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Porfolio_project]..[Nashville_Housing] 

  ---------------------------------------------------------------
  -- clean saledate
  SELECT saledate, saledateconverted
  FROM Porfolio_project..nashville_housing
  
  Update Porfolio_project..nashville_housing
  SET saledate = Convert (date, saledate)

  ALTER TABLE porfolio_project..nashville_housing
  ADD saledateconverted date

  update Porfolio_project..nashville_housing
  SET saledateconverted = CONVERT(DATE, saledate)
----------------------------------------------------
--Populate Property Address data
SELECT * 
FROM Porfolio_project..nashville_housing 
--WHERE propertyaddress is NULL
ORDER BY parcelID


SELECT a.parcelID, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM Porfolio_project..nashville_housing a
JOIN Porfolio_project..nashville_housing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is NULL
--ORDER BY parcelID


UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM Porfolio_project..nashville_housing a
JOIN Porfolio_project..nashville_housing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is NULL



----------------------------------------------------------------------------------------------------------------------
--Breaking out address columns into individual columns (address, city, state)
SELECT propertyaddress 
FROM Porfolio_project..nashville_housing

SELECT SUBSTRING(propertyaddress, 1, CHARINDEX(',' , Propertyaddress) -1) as Address
 ,SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)  +1, LEN(propertyaddress)) as Address
FROM Porfolio_project..nashville_housing

 ALTER TABLE Nashville_housing
 ADD propertySplitAddress NVARCHAR(255); 

 UPDATE Nashville_Housing
 SET propertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',' , Propertyaddress) -1) 

 
 ALTER TABLE Nashville_housing
 ADD propertySplitCity NVARCHAR(255); 

 UPDATE Nashville_Housing
 SET propertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1,LEN(propertyaddress))


SELECT *
from Porfolio_project..NASHVILLE_HOUSING

SELECT owneraddress
from Porfolio_project..nashville_housing

SELECT
PARSENAME(REPLACE(Owneraddress, ',','.'), 3)
, PARSENAME(REPLACE(Owneraddress, ',','.'), 2)
, PARSENAME(REPLACE(Owneraddress, ',','.'), 1)
FROM Porfolio_project..nashville_housing

ALTER TABLE nashville_housing
ADD OwnerSplitAddres NVARCHAR(255)

UPDATE nashville_housing
SET OwnerSplitAddres = PARSENAME(REPLACE(Owneraddress, ',','.'), 3)

ALTER TABLE nashville_housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',','.'), 2)

ALTER TABLE nashville_housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',','.'), 1)

SELECT * 
FROM nashville_housing

-----------------------------------------------------------------------
--Replace 'Y' and 'N' in SoldAsVacant as Yes and No.
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
order by 2

SELECT Soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END
FROM NASHVILLE_HOUSING

UPDATE nashville_housing
SET soldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
					WHEN soldasvacant = 'N' THEN 'No'
					ELSE soldasvacant
					END

-----------------------------------------------------------------------------------------------------------
--Remove duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	Partition BY parcelid, propertyaddress, saleprice,saledate, legalreference
	ORDER BY 
	uniqueid 
	) row_num
from nashville_housing
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress


SELECT * FROM nashville_housing

----------------------------------------------------------------------------------------
--Drop unused column
alter table porfolio_project..nashville_housing
drop column propertyaddress, saledate, owneraddress, taxdistrict

SELECT TOP 100 *
FROM Porfolio_project..nashville_housing