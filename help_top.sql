-- ########################################################################################################
--                                                                                                       --
-- File Name     : help_top.sql                                                                          --
-- Description   : Displays info about how to use top on linux                                           --
-- Comments      : N/A                                                                                   --
-- Requirements  : use top as root on UNIX servers                                                       --
-- Call Syntax   : N/A                                                                                   --
-- Last Modified : 26/03/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


-- ======================================================================
-- Dentro do top digite as letras abaixo de acordo com oq quer filtrar
-- ======================================================================
--
-- --> top -v : mostra versao do top
-- --> R - Ordena por consumo de CPU
-- --> E - Grafico do geral em K-M-G - Bytes
-- --> e - Grafico de processos em K-M-G - Bytes
-- --> L - usado para buscar um string 
-- --> m - para apresentar o grafico de memoria e muda as apresentacoes entre traco e blocos
-- --> t - apresnetar o grafico de cpu e muda as apresentacoes entre traco e blocos (Se forem varios ele mostrara todos os CPUs)
-- --> tm apresenta as infos de CPU e Memoria juntos
-- --> muda a cor do top para vermelho
-- --> ORDERNAR por coluna
     --> Shift + p: The %CPU column.
     --> Shift + m: The %MEM column.
     --> Shift + n: The PID column.
     --> Shift + t: The TIME+ column.

-- --> c - Mostra a linha de comando Full - Para ver a arvore de processos - digite V
-- --> u - para ver processos de um unico usuario, em seguida digite o usuario
-- --> i - Para ver apenas tasks ativas
-- --> n - para difinir numeros de linhas das tasks a serem mostradas
-- --> r - para mudar a prioridade de um processo, vai pedir o numero do processo e depois vai pedir o novo valor de prioridade
-- --> k - matar um processo no top, vai pedir o numero do processo 
-- --> d - muda o tempo de refresh do top - em segundos
-- --> space - Forca o top a fazer o refresh na hora



--=====================================
-- LENDO O TOP 
--=====================================

  
  
  The first line of numbers on the dashboard includes the time, how long your computer has been running, the number of people logged in, and what the load average has been for the past one, five, and 15 minutes. 
  
  The second line shows the number of tasks and their states: running, stopped, sleeping, or zombie.
  
  The third line displays the following central processing unit (CPU) values:
  
        us: Amount of time the CPU spends executing processes for people in "user space."
        sy: Amount of time spent running system "kernel space" processes.
        ni: Amount of time spent executing processes with a manually set nice value.
        id: Amount of CPU idle time.
        wa: Amount of time the CPU spends waiting for I/O to complete.
        hi: Amount of time spent servicing hardware interrupts.
        si: Amount of time spent servicing software interrupts.
        st: Amount of time lost due to running virtual machines ("steal time").
  
  
  The fourth line shows the total amount (in kibibytes) of physical memory, and how much is free, used, and buffered or cached.
  
  The fifth line shows the total amount (also in kibibytes) of swap memory, and how much is free, used, and available. The latter includes memory that's expected to be recoverable from caches.  '
  
  The column headings in the process list are as follows:
  
       PID: Process ID.
       USER: The owner of the process.
       PR: Process priority.
       NI: The nice value of the process.
       VIRT: Amount of virtual memory used by the process.
       RES: Amount of resident memory used by the process.
       SHR: Amount of shared memory used by the process.
       S: Status of the process. (See the list below for the values this field can take).
       %CPU: The share of CPU time used by the process since the last update.
       %MEM: The share of physical memory used.
       TIME+: Total CPU time used by the task in hundredths of a second.
       COMMAND: The command name or command line (name + options).
       Memory values are shown in kibibytes. The COMMAND column is off-screen, to the right---it didn't fit in the image above, but we'll see it shortly.
  
  The status of the process can be one of the following:
  
       D: Uninterruptible sleep
       R: Running
       S: Sleeping
       T: Traced (stopped)
       Z: Zombie

