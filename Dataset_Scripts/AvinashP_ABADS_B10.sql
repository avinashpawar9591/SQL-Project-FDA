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

SELECT YEAR(ActionDate) AS ApprovalYear, count(ActionType) AS NumberofDrugsApproved FROM regactiondate WHERE ActionType = 'AP' GROUP BY YEAR(ActionDate) ORDER BY ApprovalYear;


/* 1.2. Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.*/
  
SELECT YEAR(DocDate) AS ApprovalYear, count(ActionType) AS NumberofDrugsApproved FROM appdoc WHERE ActionType = 'AP' GROUP BY YEAR(DocDate) ORDER BY ApprovalYear LIMIT 3;

SELECT YEAR(DocDate) AS ApprovalYear, count(ActionType) AS NumberofDrugsApproved FROM appdoc WHERE ActionType = 'AP' GROUP BY YEAR(DocDate) ORDER BY NumberofDrugsApproved DESC LIMIT 3;



/* 1.3. Explore approval trends over the years based on sponsors. */

SELECT YEAR(r.ActionDate) AS ApprovalYear, a.SponsorApplicant AS SponsorName, COUNT(DISTINCT r.ApplNo) AS NumberOfApprovals
FROM regactiondate r JOIN application a ON r.ApplNo = a.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY ApprovalYear, SponsorName
ORDER BY ApprovalYear, NumberOfApprovals DESC;

/* 1.4 Rank sponsors based on the total number of approvals they received each year between 1939 and 1960. */

SELECT YEAR(regactiondate.ActionDate) AS ApprovalYear, application.SponsorApplicant, COUNT(regactiondate.ActionType) AS ApprovalCount,
RANK() OVER (PARTITION BY YEAR(regactiondate.ActionDate) ORDER BY COUNT(regactiondate.ActionType) DESC) AS SponsorRank
FROM application LEFT JOIN regactiondate  ON regactiondate.ApplNo = application.ApplNo
WHERE YEAR(regactiondate.ActionDate) BETWEEN 1939 AND 1960
GROUP BY YEAR(regactiondate.ActionDate), application.SponsorApplicant
ORDER BY ApprovalYear, SponsorRank;



/* 2.  Segmentation Analysis Based on Drug MarketingStatus 
2.1 Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns. */

SELECT p.ProductMktStatus, COUNT(*) AS ProductCount
FROM product p LEFT JOIN product_tecode pt ON p.ApplNo = pt.ApplNo AND p.ProductNo = pt.ProductNo
GROUP BY p.ProductMktStatus;

/* 2.2 Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. */

SELECT product.ProductMktStatus, YEAR(regactiondate.ActionDate) AS Year, COUNT(product.ApplNo) AS TotalApplications
FROM product LEFT JOIN regactiondate ON product.ApplNo = regactiondate.ApplNo AND YEAR(regactiondate.ActionDate) > 2010
GROUP BY ProductMktStatus, YEAR(regactiondate.ActionDate)
ORDER BY ProductMktStatus,YEAR(regactiondate.ActionDate);

/* 2.3 Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time. */

SELECT product.ProductMktStatus, YEAR(regactiondate.ActionDate) AS Year, COUNT(product.ApplNo) AS TotalApplications
FROM product LEFT JOIN regactiondate ON product.ApplNo = regactiondate.ApplNo AND YEAR(regactiondate.ActionDate)
GROUP BY ProductMktStatus, YEAR(regactiondate.ActionDate)
HAVING YEAR IS NOT NULL
ORDER BY ProductMktStatus,COUNT(product.ApplNo) DESC;

/*  3: Analyzing Products
3.1 Categorize Products by dosage form and analyze their distribution. */

SELECT Form AS DosageForm, Dosage, COUNT(ProductNo) AS ProductCount
FROM product
GROUP BY DosageForm, Dosage
ORDER BY ProductCount DESC;

/* 3.2 Calculate the total number of approvals for each dosage form and identify the most successful forms. */

SELECT p.Form AS DosageForm, COUNT(r.ApplNo) AS TotalApprovals
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY DosageForm
ORDER BY TotalApprovals DESC;

/* 3.3 Investigate yearly trends related to successful forms */

SELECT p.Form AS DosageForm, YEAR(r.ActionDate) AS ApprovalYear, COUNT(r.ApplNo) AS TotalApprovals
FROM product p JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY DosageForm, ApprovalYear
ORDER BY DosageForm, ApprovalYear;


/* 4: Exploring Therapeutic Classes and Approval Trends
4.1 Analyze drug approvals based on therapeutic evaluation code (TE_Code). */

SELECT p.TECode, COUNT(r.ApplNo) AS TotalApprovals
FROM product_tecode p
JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY p.TECode
ORDER BY TotalApprovals DESC;

/* 4.2 Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year. */

SELECT YEAR(r.ActionDate) AS ApprovalYear, p.TECode, COUNT(r.ApplNo) AS TotalApprovals
FROM product_tecode p JOIN regactiondate r ON p.ApplNo = r.ApplNo
WHERE r.ActionType = 'AP'
GROUP BY p.TECode, ApprovalYear
ORDER BY ApprovalYear
LIMIT 1;


