use fda;
select * from appdoctype_lookup;
select * from appdoc;
select * from application;
select * from chemtypelookup;
select * from doctype_lookup;
select * from product;
select * from product_tecode;
select * from regactiondate;
select * from reviewclass_lookup;

/* Task 1: Identifying Approval Trends */
/* 1.1. Determine the number of drugs approved each year and provide insights into the yearly trends. */

SELECT YEAR(r.ActionDate) AS ApprovalYear,
       COUNT(DISTINCT p.ApplNo) AS NumberOfDrugsApproved
FROM regactiondate r
JOIN Product p ON r.ApplNo = p.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY YEAR(r.ActionDate)
ORDER BY ApprovalYear;



/* 1.2. Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.*/

SELECT YEAR(r.ActionDate) AS ApprovalYear, COUNT(DISTINCT p.ApplNo) AS NumberOfDrugsApproved
FROM regactiondate r JOIN Product p ON r.ApplNo = p.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear
ORDER BY NumberOfDrugsApproved DESC
LIMIT 3;

SELECT YEAR(r.ActionDate) AS ApprovalYear, COUNT(DISTINCT p.ApplNo) AS NumberOfDrugsApproved
FROM regactiondate r JOIN Product p ON r.ApplNo = p.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear
ORDER BY NumberOfDrugsApproved ASC
LIMIT 3;

/* 1.3. Explore approval trends over the years based on sponsors. */

SELECT a.SponsorApplicant AS SponsorName, COUNT(DISTINCT r.ApplNo) AS NumberOfApprovals
FROM regactiondate r INNER JOIN application a ON r.ApplNo = a.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY SponsorName
ORDER BY SponsorName;

SELECT YEAR(r.ActionDate) AS ApprovalYear, a.SponsorApplicant AS SponsorName, COUNT(DISTINCT r.ApplNo) AS NumberOfApprovals
FROM regactiondate r INNER JOIN application a ON r.ApplNo = a.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear, SponsorName
ORDER BY ApprovalYear, NumberOfApprovals DESC;

SELECT a.SponsorApplicant AS SponsorName, YEAR(r.ActionDate) AS ApprovalYear,COUNT(DISTINCT r.ApplNo) AS NumberOfApprovals
FROM regactiondate r JOIN application a ON r.ApplNo = a.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY SponsorName, ApprovalYear
ORDER BY SponsorName, ApprovalYear, NumberOfApprovals DESC;

/* 1.4 Rank sponsors based on the total number of approvals they received each year between 1939 and 1960. */

SELECT YEAR(r.ActionDate) AS ApprovalYear, a.SponsorApplicant AS SponsorName, COUNT(DISTINCT r.ApplNo) AS TotalApprovals, 
RANK() OVER (PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(DISTINCT r.ActionDate) DESC) AS SponsorRank
FROM regactiondate r INNER JOIN application a ON r.ApplNo = a.ApplNo
WHERE r.ActionType = 'AP'AND YEAR(r.ActionDate) BETWEEN 1939 AND 1960
GROUP BY ApprovalYear, SponsorName 
ORDER BY ApprovalYear, SponsorRank;

/* 2.  Segmentation Analysis Based on Drug MarketingStatus 
2.1 Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns. */

SELECT ProductMktStatus, COUNT(*) AS ProductCount
FROM product
GROUP BY ProductMktStatus;

SELECT ProductMktStatus As MarketingStatus, COUNT(*) AS ProductCount,
ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM product), 2) AS Percentage
FROM product
GROUP BY MarketingStatus;

/* 2.2 Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. */

SELECT YEAR(r.ActionDate) AS ApplicationYear, p.ProductMktStatus AS MarketingStatus, COUNT(DISTINCT r.ApplNo) AS TotalApplications
FROM regactiondate r JOIN product p ON r.ApplNo = p.ApplNo
WHERE YEAR(r.ActionDate) > 2010
GROUP BY ApplicationYear, p.ProductMktStatus
ORDER BY ApplicationYear, p.ProductMktStatus;

/* 2.3 Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time. */

SELECT p.ProductMktStatus AS TopMarketingStatus, COUNT(DISTINCT r.ApplNo) AS TotalApplications
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
GROUP BY p.ProductMktStatus
ORDER BY TotalApplications DESC
LIMIT 1;

SELECT YEAR(r.ActionDate) AS ApplicationYear, COUNT(DISTINCT r.ApplNo) AS TotalApplications
FROM regactiondate r JOIN product p ON r.ApplNo = p.ApplNo
WHERE p.ProductMktStatus = '1'  -- Replace '1' with the identified top MarketingStatus value
GROUP BY ApplicationYear
ORDER BY ApplicationYear;

/*  3: Analyzing Products
3.1 Categorize Products by dosage form and analyze their distribution. */

SELECT Form AS DosageForm, ProductNo, Dosage, COUNT(ApplNo) AS ProductCount
FROM product
GROUP BY Form, ProductNo, Dosage
ORDER BY ProductCount DESC;

/* 3.2 Calculate the total number of approvals for each dosage form and identify the most successful forms. */

SELECT p.Form AS DosageForm, COUNT(r.ApplNo) AS TotalApprovals
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY DosageForm
ORDER BY TotalApprovals DESC;

/* 3.3 Investigate yearly trends related to successful forms */

SELECT p.Form AS DosageForm, YEAR(r.ActionDate) AS ApprovalYear, COUNT(DISTINCT r.ApplNo) AS TotalApprovals
FROM regactiondate r
JOIN product p ON r.ApplNo = p.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear, DosageForm
ORDER BY DosageForm, TotalApprovals, ApprovalYear DESC;

SELECT HighestDosageByYear.ApprovalYear, HighestDosageByYear.DosageForm, HighestDosageByYear.TotalApprovals
FROM (SELECT YEAR(r.ActionDate) AS ApprovalYear, p.Form AS DosageForm, COUNT(DISTINCT r.ApplNo) AS TotalApprovals,
RANK() OVER (PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(DISTINCT r.ApplNo) DESC) AS rn
FROM regactiondate r JOIN product p ON r.ApplNo = p.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear, DosageForm) AS HighestDosageByYear
WHERE HighestDosageByYear.rn = 1
ORDER BY HighestDosageByYear.ApprovalYear, HighestDosageByYear.TotalApprovals DESC;

/* 4: Exploring Therapeutic Classes and Approval Trends
4.1 Analyze drug approvals based on therapeutic evaluation code (TE_Code). */

SELECT pt.TECode, COUNT(r.ApplNo) AS TotalApprovals
FROM regactiondate r JOIN product_tecode pt ON r.ApplNo = pt.ApplNo
WHERE r.ActionType = 'AP' 
GROUP BY pt.TECode
ORDER BY TotalApprovals DESC;

/* 4.2 Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year. */

WITH TECodeApprovalCounts AS (
SELECT YEAR(r.ActionDate) AS ApprovalYear, p.TECode, COUNT(r.ApplNo) AS TotalApprovals,
RANK() OVER (PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(r.ApplNo) DESC) AS ApprovalRank
FROM product_tecode p
JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear, p.TECode)
SELECT ApprovalYear, TECode, TotalApprovals
FROM TECodeApprovalCounts
WHERE ApprovalRank = 1
ORDER BY ApprovalYear;

/* Power BI 5 - Explore approval trends over the years based on different sponsors. Uncover patterns and 
changes in approval rates among sponsors. */

SELECT YEAR(r.ActionDate) AS ApprovalYear, a.SponsorApplicant, COUNT(DISTINCT r.ApplNo) AS TotalApprovals
FROM regactiondate r
JOIN application a ON r.ApplNo = a.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear, a.SponsorApplicant
ORDER BY ApprovalYear, TotalApprovals DESC;

/* Power BI 6 - Visualize the segmentation of products based on MarketingStatus. */

SELECT ProductMktStatus, drugname, COUNT(*) AS ProductCount
FROM product
GROUP BY drugname, ProductMktStatus;

SELECT p.ProductMktStatus, p.Drugname, p.Form, p.Dosage, COUNT(DISTINCT p.ApplNo) AS ProductCount, Year(r.ActionDate) AS ApprovalYear
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
GROUP BY ProductMktStatus, Drugname, Form, Dosage, ApprovalYear;

/* Power BI 7 - Show the total number of applications for each MarketingStatus. Enable users to filter by 
years and MarketingStatus for detailed analysis. */

SELECT YEAR(rd.ActionDate) AS ApplicationYear, p.ProductMktStatus, COUNT(DISTINCT rd.ApplNo) AS TotalApplications
FROM regactiondate rd JOIN product p ON rd.ApplNo = p.ApplNo
WHERE rd.ActionType = 'AP'
GROUP BY ApplicationYear, p.ProductMktStatus
ORDER BY ApplicationYear, p.ProductMktStatus;

/* POWER BI 8 - Analyze the grouping of drugs by dosage form. Visualize the distribution of approvals across 
different forms. Identify the most successful dosage form. */

SELECT p.Form AS DosageForm, p.Drugname, COUNT(r.ApplNo) AS TotalApprovals
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY DosageForm, Drugname
ORDER BY TotalApprovals DESC;

SELECT p.Form AS DosageForm, p.Drugname, COUNT(DISTINCT r.ApplNo) AS TotalApprovals
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY DosageForm, Drugname
ORDER BY TotalApprovals DESC;

/* Power BI 9 - Visualize drug approvals based on therapeutic classes. Identify classes with the highest 
number of approvals. */

SELECT pt.TECode AS TherapeuticClass, p.Drugname, COUNT(DISTINCT r.ApplNo) AS TotalApprovals, YEAR(r.ActionDate) AS ApprovalYear
FROM product_tecode pt JOIN product p ON pt.ApplNo = p.ApplNo JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY TherapeuticClass, p.Drugname, ApprovalYear
ORDER BY TotalApprovals DESC;