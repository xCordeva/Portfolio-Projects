/* 
Cleaning DATA that I found online about housing in Nashville
-- "NashHousing" is the name that I used for the Table --
*/

select * 
from dbo.nashHousing

-- Adjusting The Date to The Right Format

alter table nashHousing
add SalesDate Date;
 
update NashHousing
Set SalesDate = CONVERT(date, SaleDate)

-- Replacing The Null Names With 'No Name'

Update NashHousing
Set OwnerName =
Case
When OwnerName is null Then 'No Name'
ELSE OwnerName
End

Select OwnerName
From NashHousing


-- Filling The Empty Property Addresses

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashHousing A
join NashHousing B
on A.ParcelID = B.ParcelID
And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

Update A
Set propertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from NashHousing A
join NashHousing B
on A.ParcelID = B.ParcelID
And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


-- Breaking Owner Address to (Address, City, State) Using Substring

select propertyAddress,
	SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1),
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
From NashHousing

Alter Table NashHOusing
Add SplittedPropAddress Nvarchar(255),
	SplittedCityAddress Nvarchar(255);


Update NashHousing
Set SplittedPropAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1),
	SplittedCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- Splitting OwnerAddress Using Parsename


Select owneraddress,
PARSENAME(Replace(OwnerAddress,',', '.'), 3),
PARSENAME(Replace(OwnerAddress,',', '.'), 2),
PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From NashHousing
where OwnerAddress is not null

Alter Table NashHousing
Add SplittedOwnerAddress NvarChar(255),
SplittedOwnerCity NvarChar (255),
SplittedOwnerState NvarChar(255);

Update NashHousing
Set 
SplittedOwnerAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3),
SplittedOwnerCity    = PARSENAME(Replace(OwnerAddress,',', '.'), 2),
SplittedOwnerState   = PARSENAME(Replace(OwnerAddress,',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
 
select distinct(Soldasvacant), COUNT(SoldAsvacant) A
from NashHousing
Group By SoldAsVacant


Update NashHousing
Set SoldAsVacant =
Case 
When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
End

-- Removing Duplicates
With RemovingDuplicatesCTE As 
(
	Select * , ROW_NUMBER() over (Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) RowNum
	From NashHousing
)
Delete
From RemovingDuplicatesCTE
where RowNum > 1

-- Deleting Unused Columns

Alter Table NashHousing
Drop Column SaleDate,  OwnerAddress, PropertyAddress


