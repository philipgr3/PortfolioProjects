
-- Data Cleaning in SQL

select *
from PortfolioProject.dbo.Nashville

-- Changing the format of saledate column

alter table PortfolioProject..Nashville
alter column saledate date

select * 
from PortfolioProject.dbo.Nashville


-- Populate Property Adress data
-- Using self join on parcelID to replace null values with the proper property adress

select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Nashville a
join PortfolioProject.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Nashville a
join PortfolioProject.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

select *
from PortfolioProject..Nashville
where PropertyAddress is null

-- Breaking down Property Address into seperate columns (Address, City)
-- Using substrings and charindex to seperate the Property Address by the ","

select propertyaddress
from PortfolioProject.dbo.Nashville

select
substring(propertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
substring(propertyAddress, charindex(',', propertyaddress) +1, len(propertyaddress) ) as City 
from PortfolioProject.dbo.Nashville

alter table PortfolioProject.dbo.Nashville
add PropertySplitAddress nvarchar(255)

update PortfolioProject.dbo.Nashville
set propertysplitaddress = substring(propertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table PortfolioProject.dbo.Nashville
add PropertySplitCity nvarchar(255)

update PortfolioProject.dbo.Nashville
set propertysplitcity = substring(propertyAddress, charindex(',', propertyaddress) +1, len(propertyaddress) )

select *
from PortfolioProject.dbo.Nashville


-- Breaking down Owner Address into 3 seperate columns (Address, City, State)
-- Using the Parsename function

select owneraddress
from PortfolioProject.dbo.Nashville

select
parsename(replace(owneraddress, ',' , '.') , 3),
parsename(replace(owneraddress, ',' , '.') , 2),
parsename(replace(owneraddress, ',' , '.') , 1)
from PortfolioProject.dbo.Nashville

alter table PortfolioProject.dbo.Nashville
add OwnerSplitAddress nvarchar(255)

update PortfolioProject.dbo.Nashville
set OwnerSplitAddress = parsename(replace(owneraddress, ',' , '.') , 3)

alter table PortfolioProject.dbo.Nashville
add OwnerSplitCity nvarchar(255)

update PortfolioProject.dbo.Nashville
set OwnerSplitCity = parsename(replace(owneraddress, ',' , '.') , 2)

alter table PortfolioProject.dbo.Nashville
add OwnerSplitState nvarchar(255)

update PortfolioProject.dbo.Nashville
set OwnerSplitState = parsename(replace(owneraddress, ',' , '.') , 1)

select * 
from PortfolioProject.dbo.Nashville


-- Replacing SoldAsVacant's  'Y' and 'N' to 'Yes' and 'No' respectively
-- Using case statement

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject.dbo.Nashville
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'	
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.Nashville


update PortfolioProject.dbo.Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'	
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

select distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProject.dbo.Nashville
group by SoldAsVacant
order by 2


-- Remove duplicates

-- We will be using the row_number() function, partitioned by some attributes to identify which columns appear more than once. We will then use a Common Table Expression (CTE) to pick the duplicates


with RowNumCTE as(
select *, 
	  row_number() over(
		partition by parcelID, 
					 propertyaddress, 
				     saledate,
					 saleprice,
					 legalreference 
		             order by 
		               uniqueID
		               ) row_num
from PortfolioProject.dbo.Nashville )

delete
from RowNumCTE
where row_num > 1



