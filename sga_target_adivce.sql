-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : sga_target_adivce.sql                                                                 --
-- Description   : Displays estimates info about SGA Size                                                --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ and DBA views.                                                      --
-- Call Syntax   : @sga_target_adivce                                                                    --
-- Last Modified : 07/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


select * from v$sga_target_advice order by sga_size;