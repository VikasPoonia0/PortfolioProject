-- cleaning data using SQL queries
select * from nashvile_housing;


-- standardize date format
update nashvile_housing
set SaleDate = str_to_date(SaleDate, '%M %e,%Y');

select * from nashvile_housing;


-- Populate property address
select *
from nashvile_housing
-- where PropertyAddress is null
order by ParcelID;

-- joining table on itsself to use parcelID 
-- and same address related to that to populate the null address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
from nashvile_housing a
join nashvile_housing b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update nashvile_housing a
join nashvile_housing b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
set a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
where a.PropertyAddress is null;



-- Breaking address into individual columns (Address, City, State)
select PropertyAddress, 
trim(substring_index(PropertyAddress, ',', 1)),
trim(substring_index(PropertyAddress, ',', -1))
from nashvile_housing;

alter table nashvile_housing
add column PropertySplitAddress varchar(255),
add column PropertySplitCity varchar(255);

update nashvile_housing
set
PropertySplitAddress = trim(substring_index(PropertyAddress, ',', 1)),
PropertySplitCity = trim(substring_index(PropertyAddress, ',', -1));

alter table nashvile_housing
add column OwnerSplitAddress varchar(255),
add column OwnerSplitCity varchar(255),
add column OwnerSplitState varchar(255);

update nashvile_housing
set
OwnerSplitAddress = trim(substring_index(OwnerAddress, ',', 1)),
OwnerSplitCity = trim(substring_index(substring_index(Owneraddress, ',', 2), ',', -1)),
OwnerSplitState = trim(substring_index(OwnerAddress, ',', -1));




-- change Y and N as Yes and No in SoldAsVacant
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvile_housing
group by SoldAsVacant;

select SoldAsVacant,
Case 
    when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
end
from nashvile_housing;

    
update nashvile_housing
set SoldAsVacant = 
    case
        when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
    end;



-- remove duplicates

with rownumCTE as (
select *, 
     row_number() over(
     partition by ParcelID,
				  PropertyAddress,
                  SalePrice,
                  SaleDate,
                  LegalReference
                  order by
					UniqueID
                    ) row_num
from nashvile_housing)

delete
from nashvile_housing
where UniqueID in (select UniqueID from rownumCTE where row_num>1); 



-- delete unused columns

alter table nashvile_housing
drop column PropertyAddress, 
drop column OwnerAddress, 
drop column TaxDistrict;

select * from nashvile_housing;