
----------------------------------------------------------------Nâng cấp 1.3 (Trước khi cài code bản mới, chạy vd dưới thử trước)
SET NOCOUNT ON--bật lệnh này để bỏ mấy thông báo cột
--ĐẦU XÓA NÀY TRƯỚC
delete QA
where hoi = '1+1'

--có 1 cái bug cực lớn mới phát hiện,
-- Ví dụ ông dạy bot là 1+1 thì bằng = 3, lúc này ông biết ông dạy sai, ông dạy lại có 2 cách:
--VD
declare @traLoi nvarchar(max)
exec PhanHoi N'1+1->3', @traLoi output
print @traLoi

--
declare @traLoi nvarchar(max)
exec PhanHoi N'1+1', @traLoi output
print @traLoi

--C1 là ông dạy thêm vào bằng lệnh có dấu "->" như 1+1->2 thì lúc này khi ông gõ 1+1 thì bot sẽ trả lời có lúc bằng 2 HAY bằng 3
--VD
declare @traLoi nvarchar(max)
exec PhanHoi N'1+1->2', @traLoi output
print @traLoi

--VD: LÚC NÀY SẼ CÓ LÚC RA 2, CÓ LÚC RA 3 (nhấn execute nhiều lần)
declare @traLoi nvarchar(max)
exec PhanHoi N'1+1', @traLoi output
print @traLoi

--Xóa để thử trường hợp C2
DELETE QA
where hoi ='1+1' and traLoi ='2'
-- tui ko ghi đè xóa kq cũ Vì tui làm vậy để 1 câu hỏi - n cách trả lời, nhưng với trường hợp trên thì có câu trả lời sai là =3


--C2 là ông dạy thử câu lệnh chẳng hạn "nói vậy là chửi bậy" (được dạy từ trước bằng lệnh @xoa), thì lúc này kết quả 1+1=3 sẽ đc lưu vào những
--câu chửi bậy, và ông chỉ cần dạy lại câu mới là 1+1=2. 
declare @traLoi nvarchar(max)
exec PhanHoi N'nói vậy là chửi bậy->@xoa', @traLoi output
print @traLoi
--

declare @traLoi nvarchar(max)
exec PhanHoi N'1+1', @traLoi output--=>lúc này kết quả =3, kết quả mình ko muốn
print @traLoi
--

declare @traLoi nvarchar(max)
exec PhanHoi N'nói vậy là chửi bậy', @traLoi output--Đưa 1+1=3 trên thành câu chửi bậy
print @traLoi

declare @traLoi nvarchar(max)
exec PhanHoi N'2', @traLoi output--Ddạy lại nói là = 2, vậy là hết? CHƯA ĐÂU!
print @traLoi

--NHƯNG!!! khi đó 1+1=3 thì vế trả lời "3" lại đc coi là câu nói bậy! NHẦM LẪN TAI HẠI ĐÓ SẼ KHIẾN ÔNG KO GÕ ĐC CON SỐ 3
--Vì nó tưởng nhầm là con số 3 là câu nói bậy.

declare @traLoi nvarchar(max)
exec PhanHoi N'3', @traLoi output--Lúc này nó sẽ BÁO LÀ 3 là câu chửi bậy!?! BUG!!!
print @traLoi

-------------------------------------------------TRƯỚC KHI ĐỌC KHÚC DƯỚI, CÀI CODE MỚI NÀY VÀO!!!!

drop proc PhanHoi--xóa code cũ
---------------------------

create proc PhanHoi
@hoi nvarchar(max),
@traLoi nvarchar(max) output
as begin --1
	if @hoi !='' begin--1.1
		update QA
		set tlGiong =0
		declare @hoi1 nvarchar(100), @hoi2 nvarchar(100), @id int
		select @id = max(idCau)
		from QA
		set @id = @id +1
		if  CHARINDEX('->',@hoi) != 0 begin--1.1.1
			update QA
			set trangThai=3
			where trangThai=5
			select @hoi1 = SUBSTRING(@hoi, 0, CHARINDEX('->',@hoi))
			select @hoi2 = SUBSTRING(@hoi, CHARINDEX('->',@hoi)+2, LEN(@hoi))
			declare @kqmax2 int
			exec traloiTrung @hoi2, @kqmax2 out
			if  @kqmax2 >80 begin--1.1.1.1
				set @traLoi = N'BẠN ĐÃ DÙNG NGÔN TỪ THIẾU PHÙ HỢP, MONG BẠN CÂN NHẮC HƠN!'
				update QA
				set trangThai=5
				where trangThai=3 and hoi = @hoi2
			end--1.1.1.1
			else begin--1.1.1.2
				insert into QA
				values(@id, @hoi1, @hoi2, 0, 0)
				set @traLoi = N'Cảm ơn bạn đã dạy <3'
			end--1.1.1.2
		end--1.1.1
		else begin--1.1.2.1b
				declare @kqmax3 int
				exec traloiTrung @hoi, @kqmax3 out
				if @kqmax3 >80 begin--1.1.2.1
					update QA
					set trangThai=3
					where trangThai=5
					set @traLoi = N'BẠN ĐÃ DÙNG NGÔN TỪ THIẾU PHÙ HỢP, MONG BẠN CÂN NHẮC HƠN!'
					delete QA
					where traLoi = '@temp'
					update QA
					set trangThai=5
					where trangThai=3 and traLoi = @hoi
				end--1.1.2.1
				else begin--1.1.2.2
					update QA
					set tlGiong =0
					declare @kqmax int, @idCau int
					exec DiemTrung @hoi, @kqmax out
					if @kqmax >= 80  and not exists(select * from QA where traLoi = N'@temp' or trangThai=2 or trangThai=4) begin--1.1.2.2.1
						Set	@idCau = (select top 1 idCau from QA where tlGiong = (select max(tlGiong) from QA) ORDER BY NEWID())
						set @traLoi = (select traLoi from QA where idCau=@idCau)
						if exists(select * from QA where trangThai=5) and @traLoi = '@xoabay' begin--1.1.2.1a
							declare @hoi7 nvarchar(max), @traLoi7 nvarchar(max)
							set @hoi7 = (select hoi from QA where trangThai=5) 
							set @traLoi7 = (select traLoi from QA where trangThai=5) 
							set @traLoi= N'CẢM ƠN BẠN NHIỀU, MÌNH ĐÃ SỬA XONG. "' + @hoi7 +' -> '+@traLoi7 + N'" KHÔNG PHẢI LÀ CÂU NÓI BẬY'
							Update QA
							set trangThai =0
							where trangThai=5

						end--1.1.2.1a
						else if exists(select * from QA where trangThai=5) and @traLoi != '@xoabay' begin
							Update QA
							set trangThai =3
							where trangThai=5
						end
						else if not exists(select * from QA where trangThai=5) and @traLoi ='@xoabay' begin--1.1.2.2.1.2
							set @traLoi=N'Mình đâu có nói gì bậy.'	
							update QA
							set tlGiong=0	
						end--1.1.2.2.1.2
						else if @traLoi ='@xoa' begin--1.1.2.2.1.1
							declare @noi nvarchar(100)
							set @noi = (select hoi from QA where trangThai=1)
							set @traLoi=N'CẢM ƠN BẠN RẤT NHIỀU, MÌNH ĐÃ BIẾT NÓI BẬY LÀ SAI, MÌNH SẼ HỌC HỎI ĐÚNG ĐẮN HƠN, VẬY KHI BẠ NÓI "'+@noi+N'" THÌ MÌNH SẼ NÓI...?'
							update QA
							set trangThai=2
							where trangThai=1	
							update QA
							set tlGiong=0	
						end--1.1.2.2.1.1
						else if @traLoi ='@huy' begin--1.1.2.2.1.2
							declare @noi1 nvarchar(100)
							set @noi1 = (select hoi from QA where trangThai=1)
							set @traLoi=N'CẢM ƠN BẠN RẤT NHIỀU, MÌNH ĐÃ HỌC NHẦM. KHI BẠN NÓI "'+@noi1+N'" THÌ MÌNH SẼ NÓI...?'
							update QA
							set trangThai=4
							where trangThai=1	
							update QA
							set tlGiong=0	
						end--1.1.2.2.1.2
						else begin--1.1.2.2.1.3
							update QA
							set trangThai=0
							where trangThai=1
							update QA
							set trangThai=1
							where idCau = @idCau
							update QA
							set tlGiong = 0
							if @kqmax <=90 begin--1.1.2.2.1.3.1 
								insert into QA
								values(@id, @hoi, @traLoi, 0, 0)
							end--1.1.2.2.1.3.1 
						end--1.1.2.2.1.3
					end--1.1.2.2.1
				else if @kqmax < 80 and not exists(select * from QA where traLoi = N'@temp' or trangThai=2 or trangThai=4) begin--1.1.2.2
					set @traLoi = N'Mình chưa học cái này, mình phải trả lời làm sao? Nếu bạn nói: "'+ @hoi+ N'". Mình sẽ trả lời:...?'
					insert into QA
					values(@id, @hoi, N'@temp', 0, 0)
					update QA
					set tlGiong=0
				end--1.1.2.2
				else if exists(select* from QA where traLoi = N'@temp') begin--1.1.2.3
					update QA
					set traLoi = @hoi
					where traLoi = N'@temp'
					set @traLoi = N'Cảm ơn bạn nhiều <3'
				end--1.1.2.3
				else if exists(select* from QA where trangThai=2) begin--1.1.2.4
					declare @hoibot nvarchar(100)
					set @hoibot = (select hoi from QA where trangThai=2)
					insert into QA
					values(@id, @hoibot, @hoi, 0, 0)
					update QA
					set trangThai=3
					where trangThai=2
					set @traLoi=N'CẢM ƠN BẠN, MÌNH ĐÃ SỬA SAI'
				end--1.1.2.4
				else if exists(select* from QA where trangThai=4) begin--1.1.2.5
					declare @hoibot1 nvarchar(100)
					set @hoibot1 = (select hoi from QA where trangThai=4)
					insert into QA
					values(@id, @hoibot1, @hoi, 0, 0)
					delete QA
					where trangThai=4
					set @traLoi=N'CẢM ƠN BẠN, MÌNH ĐÃ HỌC LẠI!'
				end--1.1.2.5
			end--1.1.2.2
		end--1.1.2.1b
	end--1.1
	else begin--1.2
		set @traLoi=N'Nói gì đi chứ pa!'
	end--1.2
end --1

--Vì thế tui nâng cấp ra 2 giải pháp backdoor:
--Giải pháp 1: Tui tạo ra lệnh hủy đi lệnh sai từ trước mà ko phải dùng đến C2(biến thành câu nói bậy để bỏ, thế nên ko dùng đc câu nói bậy đấy)
----Đầu tiên ông tạo lệnh hủy trước gồm:
--@xoa (lệnh cũ): đưa câu trả lời trước của bot thành câu nói bậy và về sau ông sẽ ko truy xuất đc, nếu truy xuất sẽ báo là câu nói bậy như ví dụ 1+1=3 trên
--@huy (lệnh new): chỉ xóa kết quả đưa câu trả lời trước của bot, dạy lại câu trả lời mới:
-- Mấy lệnh @xoa, @huy này tùy ý. Ông muốn dạy bao nhiu câu lệnh ứng với @xoa hay @huy gì cũng đc.
--vd "nói vậy là nói chửi bậy", "đừng chửi bậy"....ứng với @xoa rồi muốn dùng cái nào thì dùng
declare @traLoi nvarchar(max)
exec PhanHoi N'Nói vậy không đúng->@huy', @traLoi output--lệnh mới nâng cấp là lệnh hủy!
print @traLoi
--

declare @traLoi nvarchar(max)
exec PhanHoi N'1+1', @traLoi output--=>lúc này kết quả =3, kết quả mình ko muốn
print @traLoi
--
declare @traLoi nvarchar(max)
exec PhanHoi N'Nói vậy không đúng', @traLoi output--Để xóa kết quả 3 của 1+1 =3, lệnh đã dạy từ trước ứng với @huy
print @traLoi
--
declare @traLoi nvarchar(max)
exec PhanHoi N'2', @traLoi output --Rồi dạy lại =2!
print @traLoi

--Kết quả
declare @traLoi nvarchar(max)
exec PhanHoi N'1+1', @traLoi output--=> Từ lúc này trở đi, nếu đó là câu chửi bậy thì ông dùng lệnh ứng với @xoa
print @traLoi-- Nếu là câu ông ghi nhầm vd: 1+1 =3 thì dùng lệnh ứng với @huy như trên

--NHƯNG GIẢI SỬ TA ĐÃ ĐẶT NHẦM 1+1=2 LÀ CÂU NÓI BẬY THÌ SAO? LÀM SAO SỬA ĐC?!?!
--
declare @traLoi nvarchar(max)
exec PhanHoi N'nói vậy là chửi bậy->@xoa', @traLoi output --, (lệnh cũ)dạy câu này là lệnh bỏ câu trước thành câu chửi
print @traLoi
--

declare @traLoi nvarchar(max)
exec PhanHoi N'1+1', @traLoi output --Ra kết quả là =2!
print @traLoi
--

declare @traLoi nvarchar(max)
exec PhanHoi N'nói vậy là chửi bậy', @traLoi output -- lúc này kết quả 1+1=2 sẽ trở thành câu nói bậy! 
print @traLoi

--
declare @traLoi nvarchar(max)
exec PhanHoi N'2', @traLoi  output -- lúc này câu trả lời = 2 bị nhầm là câu nói bậy, vậy sao cứu đây ?
print @traLoi

--Chính vì thế tui phát sinh ra lệnh mới để quay lui
--@xoabay (khác với @xoa: biến thành câu nói bậy): lệnh này để chuyển từ 1 câu nói bậy thành 1 câu bình thường!

declare @traLoi nvarchar(max)
exec PhanHoi N'nói vậy là không có chửi->@xoabay', @traLoi  output
print @traLoi

declare @traLoi nvarchar(max)
exec PhanHoi N'2', @traLoi  output -- lúc này câu trả lời = 2 bị nhầm là câu nói bậy
print @traLoi

declare @traLoi nvarchar(max)
exec PhanHoi N'nói vậy là không có chửi', @traLoi  output -- lúc này 1+1=2 sẽ ko bị coi là câu chửi
print @traLoi




declare @traLoi nvarchar(max)
exec PhanHoi N'bạn gái của quang tên', @traLoi  output -- giờ ông có thể gõ đc con số 2 và dạy cho nó
print @traLoi