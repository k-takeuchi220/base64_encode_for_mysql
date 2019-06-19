 CREATE FUNCTION to_base64(param varchar(10)) RETURNS varchar(100) DETERMINISTIC
     BEGIN
       DECLARE $SECOND varchar(100);
       DECLARE $FONT_CODE varchar(100);
       DECLARE $RESULT varchar(100);
       DECLARE $RETURN_LIST varchar(100);
       DECLARE $S_POSITION int;
       DECLARE $DIFF_CODE int;
       DECLARE $SPLIT_CHA varchar(30);
       SET $RETURN_LIST = '';
       
       -- �������16�i���\��->2�i���ɕϊ���A2�i���ϊ�����conv�ŏȗ����ꂽ�A0��ǉ�
       SELECT conv(hex(param),16,2) into $SECOND;
       loop_add8: LOOP
         IF CHAR_LENGTH($SECOND) % 8 = 0 THEN
           LEAVE loop_add8;
         END IF;
         SELECT CONCAT(0,$SECOND) into $SECOND;
         ITERATE loop_add8;
       END LOOP loop_add8;
    
       -- 2�i����6�����Ƃɋ�؂�A6���ɖ����Ȃ�������0�ŕ₤
       loop_split6: LOOP
         IF CHAR_LENGTH($SECOND) % 6 = 0 THEN
           LEAVE loop_split6;
         END IF;
         SELECT concat($SECOND,0) into $SECOND;
         ITERATE loop_split6;
       END LOOP loop_split6;
       
       -- �ϊ��\�ɂ��ϊ�
       SET $S_POSITION = 1;
       loop_conversion: LOOP
         SELECT substring($SECOND, $S_POSITION , 6) into $SPLIT_CHA;
         SELECT conv($SPLIT_CHA,2,10) into $FONT_CODE;
         
         SET $DIFF_CODE =(
         CASE WHEN $FONT_CODE <= 25 THEN  65
	          WHEN $FONT_CODE <= 51 THEN  61
	          WHEN $FONT_CODE <= 61 THEN  -4
	          WHEN $FONT_CODE  = 62 THEN -19
	          WHEN $FONT_CODE  = 63 THEN -16
	          ELSE null;
	     END);
         
         SELECT unhex(conv(conv($SPLIT_CHA,2,10)+$DIFF_CODE,10,16)) into $RESULT;
         SELECT concat($RETURN_LIST,$RESULT) into $RETURN_LIST;
         SET $S_POSITION  = $S_POSITION + 6;
    	 IF  $S_POSITION >= char_length($SECOND) THEN 
    	   LEAVE loop_conversion;
         END IF;
         ITERATE loop_conversion;
       END LOOP  loop_conversion;
	   
	   -- 4�������Ƃɋ�؂�A4�����Ɍ������Ȃ�������=��ǉ�����
       loop_add_equal: LOOP
         IF char_length($RETURN_LIST) % 4 = 0 THEN
           LEAVE loop_add_equal;
         END IF;
         SELECT concat($RETURN_LIST,'=') into $RETURN_LIST;
         ITERATE loop_add_equal;
       END LOOP loop_add_equal;
       RETURN $RETURN_LIST;
     END;
     //