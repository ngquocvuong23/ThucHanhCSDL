-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT TenKyNang, CapDo
FROM KyNang
INNER JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen
FROM ChuyenGia_DuAn
INNER JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
INNER JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE DuAn.MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn
FROM DuAn
LEFT JOIN CongTy ON DuAn.MaCongTy = CongTy.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(MaChuyenGia) AS SOLUONG
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT * 
FROM ChuyenGia
WHERE NamKinhNghiem = (SELECT MAX(NamKinhNghiem) FROM ChuyenGia);

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(DuAn.MaDuAn) AS SOLUONG
FROM ChuyenGia_DuAn
INNER JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TENCONGTY, COUNT(MaDuAn) AS SOLUONG
FROM CongTy
INNER JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
GROUP BY TenCongTy;

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT TOP 1 KyNang.MaKyNang,TenKyNang,COUNT(MaChuyenGia) AS SOCHUYENGIA
FROM ChuyenGia_KyNang
INNER JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
GROUP BY KyNang.MaKyNang, TenKyNang
ORDER BY SOCHUYENGIA DESC;

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen
FROM ChuyenGia_KyNang
INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE TenKyNang = 'Python' AND CapDo >= 4;

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TOP 1 DuAn.MaDuAn,TenDuAn,COUNT(MaChuyenGia) AS SOCHUYENGIA
FROM ChuyenGia_DuAn
INNER JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
GROUP BY DuAn.MaDuAn, TenDuAn
ORDER BY SOCHUYENGIA DESC;

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT HoTen, COUNT(MaKyNang) AS SOLUONG
FROM ChuyenGia_KyNang
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT DISTINCT 
    c1.MaDuAn,
    cg1.HoTen AS ChuyenGia1,
    cg2.HoTen AS ChuyenGia2
FROM ChuyenGia_DuAn AS c1
INNER JOIN ChuyenGia_DuAn AS c2 
    ON c1.MaDuAn = c2.MaDuAn 
    AND c1.MaChuyenGia < c2.MaChuyenGia
INNER JOIN ChuyenGia AS cg1 
    ON c1.MaChuyenGia = cg1.MaChuyenGia
INNER JOIN ChuyenGia AS cg2 
    ON c2.MaChuyenGia = cg2.MaChuyenGia
ORDER BY c1.MaDuAn, ChuyenGia1, ChuyenGia2;

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT HoTen, COUNT(MaKyNang) AS SOLUONG
FROM ChuyenGia_KyNang
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE CapDo = 5
GROUP BY HoTen;

-- 21. Tìm các công ty không có dự án nào.
SELECT CongTy.MaCongTy, TenCongTy, MaDuAn
FROM CongTy
LEFT JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
WHERE MaDuAn IS NULL;

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT HoTen, TenDuAn
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
LEFT JOIN DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT ChuyenGia.MaChuyenGia, HoTen
FROM ChuyenGia_KyNang
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, HoTen
HAVING COUNT(MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT TenCongTy, SUM(NamKinhNghiem) AS TongSoNamKinhNghiem
FROM CongTy 
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
INNER JOIN ChuyenGia  ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY TenCongTy;

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT ChuyenGia.MaChuyenGia, HoTen
FROM ChuyenGia_KyNang
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE TenKyNang = 'Java' 
  AND ChuyenGia_KyNang.MaChuyenGia NOT IN (SELECT MaChuyenGia 
						  FROM ChuyenGia_KyNang 
						  INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang 
						  WHERE TenKyNang = 'Python');

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT TOP 1 ChuyenGia.MaChuyenGia, HoTen, COUNT(MaKyNang) AS SOLUONGKYNANG
FROM ChuyenGia_KyNang
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, HoTen
ORDER BY SOLUONGKYNANG DESC;

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT DISTINCT 
    cg1.HoTen AS ChuyenGia1,
    cg2.HoTen AS ChuyenGia2,
    cg1.ChuyenNganh
FROM ChuyenGia AS cg1
INNER JOIN ChuyenGia AS cg2 
    ON cg1.ChuyenNganh = cg2.ChuyenNganh 
    AND cg1.MaChuyenGia < cg2.MaChuyenGia
ORDER BY cg1.ChuyenNganh, ChuyenGia1, ChuyenGia2;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 CongTy.MaCongTy, TenCongTy, SUM(NamKinhNghiem) AS TongSoNamKinhNghiemCaoNhat
FROM CongTy 
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
INNER JOIN ChuyenGia  ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY CongTy.MaCongTy,TenCongTy
ORDER BY TongSoNamKinhNghiemCaoNhat DESC;

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT KyNang.MaKyNang, TenKyNang
FROM ChuyenGia_KyNang
INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaChuyenGia
GROUP BY KyNang.MaKyNang, TenKyNang
HAVING COUNT(DISTINCT MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia);
