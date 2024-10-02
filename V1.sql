CREATE DATABASE AEROPORTO
DROP DATABASE AEROPORTO;

CREATE TABLE voos (
    id INT PRIMARY KEY,
    destino VARCHAR(100),
    capacidade INT,
    lugares_reservados INT DEFAULT 0
);

-- Inserindo dados de exemplo
INSERT INTO voos (id, destino, capacidade) VALUES (1, 'S�o Paulo', 100);
INSERT INTO voos (id, destino, capacidade) VALUES (2, 'Rio de Janeiro', 50);

-- Adicionando a constraint ap�s a cria��o da tabela
ALTER TABLE voos
ADD CONSTRAINT chk_lugares_reservados CHECK (lugares_reservados <= capacidade);

-- Fun��o para verificar a consist�ncia do banco
CREATE PROCEDURE VerificarConsistencia
AS
BEGIN
    SELECT id, destino, capacidade, lugares_reservados 
    FROM voos;
	
END;

-- Transa��o bem-sucedida
BEGIN TRY
    DECLARE @voo_id INT = 1;
    DECLARE @lugares_a_reservar INT = 1;

    PRINT 'Iniciando transa��o bem-sucedida...';
    BEGIN TRANSACTION;

    -- Verifica se ainda h� lugares dispon�veis
    DECLARE @capacidade INT;
    DECLARE @lugares_reservados INT;

    SELECT @capacidade = capacidade, @lugares_reservados = lugares_reservados 
    FROM voos 
    WHERE id = @voo_id;

    IF @lugares_reservados + @lugares_a_reservar > @capacidade
    BEGIN
        RAISERROR('N�o h� lugares dispon�veis para reserva!', 16, 1);
        ROLLBACK;
    END

    -- Atualiza o n�mero de lugares reservados
    UPDATE voos
    SET lugares_reservados = lugares_reservados + @lugares_a_reservar
    WHERE id = @voo_id;

    COMMIT;
    PRINT 'Transa��o bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transa��o abortada: ' + ERROR_MESSAGE();
END CATCH;

-- Verificando consist�ncia ap�s transa��o bem-sucedida
PRINT 'Verificando consist�ncia ap�s transa��o bem-sucedida:';
EXEC VerificarConsistencia;

-- Transa��o abortada
BEGIN TRY
    DECLARE @voo_id INT = 1;
    DECLARE @lugares_a_reservar INT = 200; -- Tentativa de reservar mais lugares do que a capacidade

    PRINT 'Iniciando transa��o abortada...';
    BEGIN TRANSACTION;

    DECLARE @capacidade INT;
    DECLARE @lugares_reservados INT;
	

    SELECT @capacidade = capacidade, @lugares_reservados = lugares_reservados 
	

    FROM voos 
    WHERE id = @voo_id;

	

    IF @lugares_reservados + @lugares_a_reservar > @capacidade
    BEGIN
        RAISERROR('N�o h� lugares suficientes dispon�veis para reservar!', 16, 1);
        ROLLBACK 
    END

    -- Atualiza o n�mero de lugares reservados
    UPDATE voos
    SET lugares_reservados = lugares_reservados + @lugares_a_reservar
    WHERE id = @voo_id;

    COMMIT;
    PRINT 'Transa��o bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transa��o abortada: ' + ERROR_MESSAGE();
END CATCH;

-- Verificando consist�ncia ap�s transa��o abortada
PRINT 'Verificando consist�ncia ap�s transa��o abortada:';
EXEC VerificarConsistencia;

--Simulando Rollback para savepoint

BEGIN TRY
    DECLARE @voo_id INT = 1;
    DECLARE @lugares_a_reservar INT = 200; -- Tentativa de reservar mais lugares do que a capacidade

    PRINT 'Iniciando transa��o...';
    BEGIN TRANSACTION;

    -- Salva o estado da transa��o com um SAVEPOINT (A1)
    SAVE TRANSACTION A1;

    DECLARE @capacidade INT;
    DECLARE @lugares_reservados INT;

    SELECT @capacidade = capacidade, @lugares_reservados = lugares_reservados 
    FROM voos 
    WHERE id = @voo_id;

    IF @lugares_reservados + @lugares_a_reservar > @capacidade
    BEGIN
        RAISERROR('N�o h� lugares suficientes dispon�veis para reservar!', 16, 1);
        ROLLBACK; -- Reverte a transa��o em caso de erro
    END

    -- Aqui, vamos for�ar um erro ao tentar atualizar com um valor inv�lido
    UPDATE voos
    SET lugares_reservados = NULL -- For�ando um erro, pois NULL n�o � um valor v�lido para reservas
    WHERE id = @voo_id;

    COMMIT; -- Confirma a transa��o se tudo estiver correto
    PRINT 'Transa��o bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    -- Se ocorrer um erro, reverte para o SAVEPOINT A1
    IF XACT_STATE() <> 0 -- Verifica os status da Transa��o 0 para inativa e 1 para ativa
    BEGIN
        ROLLBACK TRANSACTION A1; -- Retorna ao SAVEPOINT A1
        PRINT 'Retornando ao SAVEPOINT A1.';
    END
    PRINT 'Transa��o abortada: ' + ERROR_MESSAGE(); -- Imprime a mensagem de erro
END CATCH;

select * from voos
delete from voos
where id = 2;
-- Simulando uma falha do sistema
BEGIN TRY
    DECLARE @voo_id INT = 2;
    DECLARE @lugares_a_reservar INT = 1;

    PRINT 'Iniciando transa��o com falha do sistema...';
    BEGIN TRANSACTION;

    -- Simulando uma falha do sistema
    IF @voo_id = 2 AND @lugares_a_reservar = 1
    BEGIN
        RAISERROR('Falha do sistema ao tentar reservar!', 16, 1);
        ROLLBACK 
    END

    -- Atualiza o n�mero de lugares reservados
    UPDATE voos
    SET lugares_reservados = lugares_reservados + @lugares_a_reservar
    WHERE id = @voo_id;

    COMMIT;
    PRINT 'Transa��o bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transa��o abortada: ' + ERROR_MESSAGE();
END CATCH;

-- Verificando consist�ncia ap�s falha do sistema
PRINT 'Verificando consist�ncia ap�s falha do sistema:';
EXEC VerificarConsistencia;