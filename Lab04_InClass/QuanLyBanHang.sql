--19. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua? 
SELECT COUNT(*) AS SoHoaDon
FROM HOADON
WHERE MAKH IS NULL;

--20. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006. 
SELECT COUNT(DISTINCT MASP) AS SoSanPham
FROM CTHD
WHERE SOHD IN (SELECT SOHD FROM HOADON WHERE YEAR(NGHD) = 2006);

--21. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu? 
SELECT MAX(TRIGIA) AS TriGiaCaoNhat, MIN(TRIGIA) AS TriGiaThapNhat
FROM HOADON;

--22. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu? 
SELECT AVG(TRIGIA) AS TriGiaTrungBinh
FROM HOADON
WHERE YEAR(NGHD) = 2006;

--23. Tính doanh thu bán hàng trong năm 2006. 
SELECT SUM(TRIGIA) AS DoanhThu
FROM HOADON
WHERE YEAR(NGHD) = 2006;

--24. Tìm số hóa đơn có trị giá cao nhất trong năm 2006. 
SELECT SOHD
FROM HOADON
WHERE TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = 2006);

--25. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006. 
SELECT HOTEN
FROM KHACHHANG 
INNER JOIN HOADON ON HOADON.MAKH = KHACHHANG.MAKH
WHERE TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = 2006);

--26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất. 
SELECT TOP 3 MAKH, HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC;

--27. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC);

--28. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức  
--giá cao nhất (của tất cả các sản phẩm). 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Thai Lan' AND GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC);

--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức 
--giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất). 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM WHERE NUOCSX = 'Trung Quoc' ORDER BY GIA DESC);

--30. * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng). 
SELECT TOP 3 MAKH, HOTEN, DOANHSO,
       RANK() OVER (ORDER BY DOANHSO DESC) AS XepHang
FROM KHACHHANG;

--31. Tính tổng số sản phẩm do “Trung Quoc” sản xuất. 
SELECT COUNT(*) AS TongSanPham
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

--32. Tính tổng số sản phẩm của từng nước sản xuất. 
SELECT NUOCSX, COUNT(*) AS TongSanPham
FROM SANPHAM
GROUP BY NUOCSX;

--33. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. 
SELECT NUOCSX, MAX(GIA) AS GiaCaoNhat, MIN(GIA) AS GiaThapNhat, AVG(GIA) AS GiaTrungBinh
FROM SANPHAM
GROUP BY NUOCSX;

--34. Tính doanh thu bán hàng mỗi ngày. 
SELECT NGHD, SUM(TRIGIA) AS DoanhThu
FROM HOADON
GROUP BY NGHD;

--35. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006. 
SELECT MASP, SUM(SL) AS TongSoLuong
FROM CTHD
WHERE SOHD IN (SELECT SOHD FROM HOADON WHERE MONTH(NGHD) = 10 AND YEAR(NGHD) = 2006)
GROUP BY MASP;

--36. Tính doanh thu bán hàng của từng tháng trong năm 2006. 
SELECT MONTH(NGHD) AS Thang, SUM(TRIGIA) AS DoanhThu
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD);

--37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau. 
SELECT SOHD
FROM CTHD
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) >= 4;

--38. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau). 
SELECT SOHD
FROM CTHD 
INNER JOIN SANPHAM  ON CTHD.MASP = SANPHAM.MASP
WHERE SANPHAM.NUOCSX = 'Viet Nam'
GROUP BY SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3;

--39. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.  
SELECT TOP 1 KHACHHANG.MAKH, KHACHHANG.HOTEN, COUNT(HOADON.SOHD) AS SoLanMua
FROM KHACHHANG 
INNER JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
GROUP BY KHACHHANG.MAKH, KHACHHANG.HOTEN
ORDER BY SoLanMua DESC;

--40. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? 
SELECT TOP 1 MONTH(NGHD) AS Thang, SUM(TRIGIA) AS DoanhSo
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY DoanhSo DESC;

--41. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006. 
SELECT TOP 1 CTHD.MASP, SANPHAM.TENSP, SUM(CTHD.SL) AS TongSoLuong
FROM CTHD 
INNER JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE CTHD.SOHD IN (SELECT SOHD FROM HOADON WHERE YEAR(NGHD) = 2006)
GROUP BY CTHD.MASP, SANPHAM.TENSP
ORDER BY TongSoLuong ASC;

--42. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. 
SELECT NUOCSX, MASP, TENSP, GIA
FROM SANPHAM SP1
WHERE GIA = (SELECT MAX(GIA) FROM SANPHAM SP2 WHERE SP2.NUOCSX = SP1.NUOCSX);

--43. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau. 
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

--44. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT TOP 1 KHACHHANG.MAKH, KHACHHANG.HOTEN, COUNT(HOADON.SOHD) AS SoLanMua
FROM KHACHHANG 
INNER JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
WHERE KHACHHANG.MAKH IN (SELECT TOP 10 MAKH FROM KHACHHANG ORDER BY DOANHSO DESC)
GROUP BY KHACHHANG.MAKH, KHACHHANG.HOTEN
ORDER BY SoLanMua DESC;
