-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 HoTen, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia 
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen
ORDER BY SoLuongKyNang DESC;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen AS ChuyenGia2
FROM ChuyenGia c1
INNER JOIN ChuyenGia c2 ON c1.MaChuyenGia < c2.MaChuyenGia
WHERE c1.ChuyenNganh = c2.ChuyenNganh AND ABS(c1.NamKinhNghiem - c2.NamKinhNghiem) <= 2;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT TenCongTy, COUNT(DuAn.MaDuAn) AS SoLuongDuAn, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy 
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
INNER JOIN ChuyenGia  ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT DISTINCT ChuyenGia.MaChuyenGia, HoTen
FROM ChuyenGia 
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE CapDo >= 5
AND NOT EXISTS (
    SELECT DISTINCT ChuyenGia.MaChuyenGia, HoTen FROM ChuyenGia
	INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
    WHERE CapDo < 3);

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT ChuyenGia.MaChuyenGia, HoTen, COUNT(MaDuAn) AS SoLuongDuAn
FROM ChuyenGia 
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia ,HoTen;

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
SELECT DISTINCT ChuyenGia_KyNang.MaChuyenGia, HoTen,TenKyNang, CapDo AS CapDoCaoNhat
FROM KyNang AS KN
INNER JOIN ChuyenGia_KyNang ON KN.MaKyNang = ChuyenGia_KyNang.MaKyNang
INNER JOIN ChuyenGia ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE CapDo = (
    SELECT MAX(CapDo)
    FROM ChuyenGia_KyNang
    WHERE KN.MaKyNang = ChuyenGia_KyNang.MaKyNang)
GROUP BY  ChuyenGia_KyNang.MaChuyenGia, HoTen,TenKyNang, CapDo
ORDER BY TenKyNang;

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh, 
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ChuyenGia) AS TyLePhanTram
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT k1.TenKyNang AS KyNang1, k2.TenKyNang AS KyNang2, COUNT(*) AS SoLanXuatHien
FROM ChuyenGia_KyNang AS ck1
INNER JOIN ChuyenGia_KyNang AS ck2 ON ck1.MaChuyenGia = ck2.MaChuyenGia AND ck1.MaKyNang < ck2.MaKyNang
INNER JOIN KyNang AS k1 ON ck1.MaKyNang = k1.MaKyNang
INNER JOIN KyNang AS k2 ON ck2.MaKyNang = k2.MaKyNang
GROUP BY k1.TenKyNang, k2.TenKyNang
ORDER BY SoLanXuatHien DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT TenCongTy, AVG(DATEDIFF(day, DuAn.NgayBatDau, DuAn.NgayKetThuc)) AS SoNgayTrungBinh
FROM CongTy 
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
WITH SkillCombination AS (
    SELECT ChuyenGia.MaChuyenGia, STRING_AGG(TenKyNang, ',') AS Skills
    FROM ChuyenGia_KyNang 
    INNER JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
    INNER JOIN ChuyenGia ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
    GROUP BY ChuyenGia.MaChuyenGia)
SELECT sc.MaChuyenGia, ChuyenGia.HoTen, sc.Skills
FROM SkillCombination sc
INNER JOIN ChuyenGia ON sc.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE NOT EXISTS (
    SELECT 1
    FROM SkillCombination sc2
    WHERE sc.MaChuyenGia != sc2.MaChuyenGia
    AND sc.Skills = sc2.Skills)
ORDER BY ChuyenGia.HoTen;

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT HoTen, COUNT(ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn, SUM(ChuyenGia_KyNang.CapDo) AS TongCapDo
FROM ChuyenGia 
INNER JOIN ChuyenGia_DuAn  ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen
ORDER BY SoLuongDuAn DESC, TongCapDo DESC;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT ChuyenGia_DuAn.MaDuAn,TenDuAn
FROM DuAn 
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
INNER JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY ChuyenGia_DuAn.MaDuAn,TenDuAn
HAVING COUNT(DISTINCT ChuyenGia.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT TenCongTy, 
       SUM(CASE WHEN TrangThai = 'Hoàn thành' THEN 1 ELSE 0 END) * 100.0 / COUNT(MaDuAn) AS TyLeThanhCong
FROM CongTy 
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2, TenKyNang, ck1.CapDo AS CapDo1, ck2.CapDo AS CapDo2
FROM ChuyenGia AS cg1
INNER JOIN ChuyenGia_KyNang AS ck1 ON cg1.MaChuyenGia = ck1.MaChuyenGia
INNER JOIN KyNang ON ck1.MaKyNang = KyNang.MaKyNang
INNER JOIN ChuyenGia AS cg2 ON cg1.MaChuyenGia < cg2.MaChuyenGia
INNER JOIN ChuyenGia_KyNang AS ck2 ON cg2.MaChuyenGia = ck2.MaChuyenGia AND ck1.MaKyNang = ck2.MaKyNang
WHERE ck1.CapDo >= 4 AND ck2.CapDo <= 2 OR ck1.CapDo <= 2 AND ck2.CapDo >= 4;
