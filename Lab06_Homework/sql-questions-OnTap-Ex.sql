-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger

-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT * 
FROM ChuyenGia;
--2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email 
FROM ChuyenGia 
WHERE GioiTinh = N'Nữ';
--3. Liệt kê các công ty có trên 100 nhân viên.
SELECT * 
FROM CongTy 
WHERE SoNhanVien > 100;
--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau
FROM DuAn
WHERE YEAR(NgayBatDau) = 2023;

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(CGDA.MaDuAn) AS SoLuongDuAnThamGia
FROM ChuyenGia CG
INNER JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia =  CG.MaChuyenGia
GROUP BY HoTen;

--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT CGDA.MaDuAn, TenDuAn
FROM ChuyenGia_DuAn CGDA
INNER JOIN DuAn ON DuAn.MaDuAn = CGDA.MaDuAn
INNER JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
INNER JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
INNER JOIN KyNang ON KyNang.MaKyNang = CGKN.MaKyNang
WHERE TenKyNang = N'Python' AND CapDo >= 4;

--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT CongTy.MaCongTy, TenCongTy, COUNT(MaDuAn) AS SoLuongDuAnDangThucThien
FROM CongTy
INNER JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTY
WHERE TrangThai = N'Đang thực hiện'
GROUP BY CongTy.MaCongTy, TenCongTy;

--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT MaChuyenGia, HoTen, ChuyenNganh, NamKinhNghiem
FROM ChuyenGia cg1
WHERE NamKinhNghiem = (SELECT Max(NamKinhNghiem)
						FROM ChuyenGia cg2
						WHERE cg2.ChuyenNganh = cg1.ChuyenNganh);

--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT cg1.MaChuyenGia AS MaChuyenGia1, cg2.MaChuyenGia AS MaChuyenGia2, da.TenDuAn
FROM ChuyenGia_DuAn cg1
INNER JOIN ChuyenGia_DuAn cg2 ON cg1.MaDuAn = cg2.MaDuAn AND cg1.MaChuyenGia < cg2.MaChuyenGia
INNER JOIN DuAn da ON cg1.MaDuAn = da.MaDuAn
ORDER BY cg1.MaChuyenGia, cg2.MaChuyenGia;

-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT MaChuyenGia, DuAn.MaDuAn, SUM(DATEDIFF(DAY,NgayThamGia,NgayKetThuc)) AS TongThoiGian
FROM ChuyenGia_DuAn
INNER JOIN DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY MaChuyenGia, DuAn.MaDuAn;

--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT CongTy.MaCongTy, TenCongTy
FROM CongTy
INNER JOIN DuAn ON DuAn.MaCongTy = CongTy.MaCongTy
GROUP BY CongTy.MaCongTy, CongTy.TenCongTy
HAVING CAST(SUM(CASE WHEN DuAn.TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) AS FLOAT) /
    CAST(COUNT(*) AS FLOAT) > 0.9;

--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT DISTINCT TOP 3 KyNang.MaKyNang, TenKyNang, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoLuongYeuCau
FROM ChuyenGia_DuAn
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
GROUP BY KyNang.MaKyNang, TenKyNang
ORDER BY COUNT(ChuyenGia_KyNang.MaKyNang) DESC;

--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
SELECT
    CASE 
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        WHEN NamKinhNghiem > 5 THEN 'Senior'
    END AS CapDoKinhNghiem,
    AVG(Luong) AS LuongTrungBinh
FROM ChuyenGia
GROUP BY 
    CASE 
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        WHEN NamKinhNghiem > 5 THEN 'Senior'
    END;

--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT DuAn.MaDuAn, TenDuAn 
FROM DuAn
INNER JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
INNER JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY DuAn.MaDuAn, TenDuAn 
HAVING (SELECT DISTINCT COUNT(ChuyenNganh)) = (SELECT DISTINCT COUNT(ChuyenNganh) FROM ChuyenGia);

-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
ALTER TABLE CongTy
ADD SoLuongDuAn tinyINT

CREATE TRIGGER CapNhapSoLuongDuAn
ON DuAn
AFTER INSERT, DELETE
AS
BEGIN
	UPDATE CongTy
	SET SoLuongDuAn = (SELECT COUNT(*) FROM DuAn WHERE CongTy.MaCongTy = DuAn.MaCongTy);

END;

--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TRIGGER GhiLogKhiCoSuThayDoi
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		INSERT INTO ThongBao(MaChuyenGia, NgayThongBao, NoiDung)
		SELECT INSERTED.MaChuyenGia, GETDATE(), 'Bảng Chuyên Gia đã được cập nhập'
		FROM INSERTED
	END
	ELSE IF EXISTS (SELECT * FROM INSERTED)
	BEGIN
		INSERT INTO ThongBao(MaChuyenGia, NgayThongBao, NoiDung)
		SELECT INSERTED.MaChuyenGia, GETDATE(), 'Bảng Chuyên Gia đã được thêm'
		FROM INSERTED
	END
	ELSE IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		INSERT INTO ThongBao(MaChuyenGia, NgayThongBao, NoiDung)
		SELECT deleted.MaChuyenGia, GETDATE(), 'Bảng Chuyên Gia đã được xóa'
		FROM deleted
	END
END;

--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER ChuyenGiaKhongThamGiaQuaNamDuAn
ON ChuyenGia_DuAn
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT * FROM INSERTED WHERE (SELECT COUNT(*) FROM ChuyenGia_DuAn WHERE ChuyenGia_DuAn.MaChuyenGia = inserted.MaChuyenGia) > 5)
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc'
	END
END;

--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
ALTER TABLE ChuyenGia
add TrangThaiCongViec NVARCHAR(50)

CREATE TRIGGER CapNhapTrangThaiHoanThanh
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
	UPDATE DA
	SET TrangThai = N'Hoàn thành'
	FROM DuAn DA INNER JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaDuAn = DA.MaDuAn
	WHERE NOT EXISTS (SELECT * FROM ChuyenGia WHERE ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia AND ChuyenGia.TrangThaiCongViec = N'Chưa kết thúc')
END;

--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
CREATE TRIGGER trg_UpdateRating_CongTy
ON DuAn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE CongTy
    SET DiemDanhGiaTrungBinh = (
        SELECT AVG(DiemDanhGia)
        FROM DuAn
        WHERE DuAn.MaCongTy = CongTy.MaCongTy
    )
    WHERE MaCongTy IN (
        SELECT MaCongTy FROM inserted
        UNION
        SELECT MaCongTy FROM deleted
    );
END;