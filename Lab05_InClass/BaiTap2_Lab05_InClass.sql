--BAI TAP 2: Sinh viên hoàn thành Phần I bài tập QuanLyGiaoVu câu 9, 10 và từ câu 15 đến câu 24.

-- 9. Lớp trưởng của một lớp phải là học viên của lớp đó. 
CREATE TRIGGER trg_loptruong
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		LEFT JOIN HOCVIEN HV ON I.MALOP = HV.MALOP AND I.TRGLOP = HV.MAHV
		WHERE HV.MAHV IS NULL )
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

-- 10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER trg_truongkhoa
ON KHOA
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		LEFT JOIN GIAOVIEN GV ON I.MAKHOA = GV.MAKHOA AND I.TRGKHOA = GV.MAGV
		WHERE GV.MAGV IS NULL OR GV.HOCVI NOT IN ('TS','PTS'))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này. 
CREATE TRIGGER trg_ngthi_ketquathi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN GIANGDAY GD ON I.MAMH = GD.MAMH
		WHERE I.NGTHI < GD.DENNGAY OR GD.DENNGAY < GETDATE())
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn. 
CREATE TRIGGER trg_somonhoc_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN GIANGDAY GD ON I.MALOP = GD.MALOP
		WHERE I.HOCKY = GD.HOCKY AND I.NAM = GD.NAM
		GROUP BY GD.MALOP, GD.HOCKY, GD.NAM
		HAVING COUNT(GD.MAMH) > 3)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. 
CREATE TRIGGER trg_siso_lop
ON HOCVIEN
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    UPDATE LOP
    SET SISO = (
        SELECT COUNT(*)
        FROM HOCVIEN
        WHERE HOCVIEN.MALOP = LOP.MALOP
    )
    FROM LOP
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.MALOP = LOP.MALOP
        UNION
        SELECT 1
        FROM deleted d
        WHERE d.MALOP = LOP.MALOP
    )
END;

--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng 
--một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”). 
CREATE TRIGGER trg_dieukien
ON DIEUKIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		WHERE I.MAMH = I.MAMH_TRUOC)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
		RETURN;
	END
	
	IF EXISTS (
		SELECT 1 
		FROM inserted I
		INNER JOIN DIEUKIEN DK ON DK.MAMH = I.MAMH_TRUOC AND DK.MAMH_TRUOC = I.MAMH)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
		RETURN;
	END

	PRINT 'THANHCONG'
END;

--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau. 
CREATE TRIGGER trg_mucluong_giaovien
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT * 
		FROM inserted I 
		WHERE EXISTS (
			SELECT * 
			FROM GIAOVIEN GV 
			WHERE I.HOCHAM = GV.HOCHAM AND I.HOCVI = GV.HOCVI AND I.HESO = GV.HESO AND I.MUCLUONG != GV.MUCLUONG)
		)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5. 
CREATE TRIGGER trg_thilai_ketquathi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE I.LANTHI > 1 AND (
			SELECT DIEM
			FROM KETQUATHI KQT
			WHERE I.MAHV = KQT.MAHV AND I.MAMH = KQT.MAMH AND KQT.LANTHI = I.LANTHI - 1) >= 5)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

-- 21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học). 
CREATE TRIGGER trg_ngaythi_ketquathi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE I.NGTHI < (
			SELECT NGTHI
			FROM KETQUATHI KQT
			WHERE I.MAHV = KQT.MAHV AND I.MAMH = KQT.MAMH AND KQT.LANTHI = I.LANTHI - 1))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

-- 22. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau 
--khi học xong những môn học phải học trước mới được học những môn liền sau). 
CREATE TRIGGER trg_phancong_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE (
			SELECT MAMH_TRUOC 
			FROM DIEUKIEN 
			WHERE DIEUKIEN.MAMH = I.MAMH) IS NOT NULL AND
			
			NOT EXISTS (
				SELECT 1 
				FROM GIANGDAY GD
				WHERE GD.MALOP = I.MALOP AND 
					GD.MAMH = (
						SELECT MAMH_TRUOC 
						FROM DIEUKIEN 
						WHERE DIEUKIEN.MAMH = I.MAMH) AND
					GD.DENNGAY < I.TUNGAY))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;

-- 23. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER trg_monthuockhoa_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted I
		WHERE (SELECT MAKHOA FROM GIAOVIEN WHERE GIAOVIEN.MAGV = I.MAGV) != (SELECT MAKHOA FROM MONHOC WHERE MONHOC.MAMH = I.MAMH))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'that bai'
	END
	ELSE
		PRINT 'thanh cong'
END;