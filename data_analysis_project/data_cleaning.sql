-- data cleaning of the dataset of nashville housing

select * 
from PortfolioProjects..NashvilleHousing

-- Standardize date format

select SaleDate, CONVERT(Date, SaleDate) as formatDate
from PortfolioProjects..NashvilleHousing

-- it doesn't work as expected
update PortfolioProjects..NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

-- add new column using alter 
alter table PortfolioProjects..NashvilleHousing
add saleDateConverted Date

-- then add the date in perfect format
update PortfolioProjects..NashvilleHousing
set saleDateConverted = CONVERT(Date, SaleDate)

select saleDateConverted
from PortfolioProjects..NashvilleHousing

-----------------------------------------------------
-- Populate property address

select PropertyAddress
from PortfolioProjects..NashvilleHousing
where PropertyAddress is Null

-- fill the null places using the record of the parcel Id's
select org.ParcelID, org.PropertyAddress, cpy.ParcelID, cpy.PropertyAddress, ISNULL(org.PropertyAddress, cpy.PropertyAddress) as propertyAddressFill
from PortfolioProjects..NashvilleHousing as org
join PortfolioProjects..NashvilleHousing as cpy
	on org.ParcelID = cpy.ParcelID
	and org.[UniqueID ] <> cpy.[UniqueID ]
where org.PropertyAddress is null

update org
set PropertyAddress = ISNULL(org.PropertyAddress, cpy.PropertyAddress)
from PortfolioProjects..NashvilleHousing as org
join PortfolioProjects..NashvilleHousing as cpy
	on org.ParcelID = cpy.ParcelID
	and org.[UniqueID ] <> cpy.[UniqueID ]
where org.PropertyAddress is null


-- breaking out address into individual columns

select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
add PropertySplitCity nvarchar(255);

alter table PortfolioProjects..NashvilleHousing
add PropertySplitAddress nvarchar(255)

update PortfolioProjects..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 
from PortfolioProjects..NashvilleHousing

update PortfolioProjects..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
from PortfolioProjects..NashvilleHousing

select PropertySplitCity, PropertySplitAddress
from PortfolioProjects..NashvilleHousing

-- for owner address
select PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Country
,trim(PARSENAME(Replace(OwnerAddress, ',', '.'), 2)) as City
,trim(PARSENAME(Replace(OwnerAddress, ',', '.'), 1)) as Address
from PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table PortfolioProjects..NashvilleHousing
add OwnerSplitCity nvarchar(255)

alter table PortfolioProjects..NashvilleHousing
add OwnerSplitState nvarchar(255)

update PortfolioProjects..NashvilleHousing
set OwnerSplitAddress = Trim(Parsename( replace(ownerAddress,',','.'), 3))
from PortfolioProjects..NashvilleHousing

update PortfolioProjects..NashvilleHousing
set OwnerSplitCity = Trim(Parsename( replace(ownerAddress,',','.'), 2))
from PortfolioProjects..NashvilleHousing

update PortfolioProjects..NashvilleHousing
set OwnerSplitState = Trim(Parsename( replace(ownerAddress,',','.'), 1))
from PortfolioProjects..NashvilleHousing

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProjects..NashvilleHousing

-- Change Y and N to Yes and No

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
end, count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
group by SoldAsVacant

update PortfolioProjects..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
end

-- remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over(
Partition by ParcelID,
			LandUse,
			PropertyAddress,
			SaleDate,
			LegalReference
			order by
				UniqueID
) as row_num
from PortfolioProjects..NashvilleHousing
)

delete
--select *
from RowNumCTE
where row_num>1

-- delete unused columns

select *
from PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProjects..NashvilleHousing
drop column saledate

