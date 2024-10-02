CREATE DATABASE AEROPORTO
DROP DATABASE AEROPORTO;

CREATE TABLE voos (
    id INT PRIMARY KEY,
    destino VARCHAR(100),
    capacidade INT,
    lugares_reservados INT DEFAULT 0
);

-- Inserindo dados de exemplo
INSERT INTO voos (id, destino, capacidade) VALUES (1, 'São Paulo', 100);
INSERT INTO voos (id, destino, capacidade) VALUES (2, 'Rio de Janeiro', 50);

-- Adicionando a constraint após a criação da tabela
ALTER TABLE voos
ADD CONSTRAINT chk_lugares_reservados CHECK (lugares_reservados <= capacidade);

-- Função para verificar a consistência do banco
CREATE PROCEDURE VerificarConsistencia
AS
BEGIN
    SELECT id, destino, capacidade, lugares_reservados 
    FROM voos;
	
END;

-- Transação bem-sucedida
BEGIN TRY
    DECLARE @voo_id INT = 1;
    DECLARE @lugares_a_reservar INT = 1;

    PRINT 'Iniciando transação bem-sucedida...';
    BEGIN TRANSACTION;

    -- Verifica se ainda há lugares disponíveis
    DECLARE @capacidade INT;
    DECLARE @lugares_reservados INT;

    SELECT @capacidade = capacidade, @lugares_reservados = lugares_reservados 
    FROM voos 
    WHERE id = @voo_id;

    IF @lugares_reservados + @lugares_a_reservar > @capacidade
    BEGIN
        RAISERROR('Não há lugares disponíveis para reserva!', 16, 1);
        ROLLBACK;
    END

    -- Atualiza o número de lugares reservados
    UPDATE voos
    SET lugares_reservados = lugares_reservados + @lugares_a_reservar
    WHERE id = @voo_id;

    COMMIT;
    PRINT 'Transação bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transação abortada: ' + ERROR_MESSAGE();
END CATCH;

-- Verificando consistência após transação bem-sucedida
PRINT 'Verificando consistência após transação bem-sucedida:';
EXEC VerificarConsistencia;

-- Transação abortada
BEGIN TRY
    DECLARE @voo_id INT = 1;
    DECLARE @lugares_a_reservar INT = 200; -- Tentativa de reservar mais lugares do que a capacidade

    PRINT 'Iniciando transação abortada...';
    BEGIN TRANSACTION;

    DECLARE @capacidade INT;
    DECLARE @lugares_reservados INT;
	

    SELECT @capacidade = capacidade, @lugares_reservados = lugares_reservados 
	

    FROM voos 
    WHERE id = @voo_id;

	

    IF @lugares_reservados + @lugares_a_reservar > @capacidade
    BEGIN
        RAISERROR('Não há lugares suficientes disponíveis para reservar!', 16, 1);
        ROLLBACK 
    END

    -- Atualiza o número de lugares reservados
    UPDATE voos
    SET lugares_reservados = lugares_reservados + @lugares_a_reservar
    WHERE id = @voo_id;

    COMMIT;
    PRINT 'Transação bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transação abortada: ' + ERROR_MESSAGE();
END CATCH;

-- Verificando consistência após transação abortada
PRINT 'Verificando consistência após transação abortada:';
EXEC VerificarConsistencia;

--Simulando Rollback para savepoint

BEGIN TRY
    DECLARE @voo_id INT = 1;
    DECLARE @lugares_a_reservar INT = 200; -- Tentativa de reservar mais lugares do que a capacidade

    PRINT 'Iniciando transação...';
    BEGIN TRANSACTION;

    -- Salva o estado da transação com um SAVEPOINT (A1)
    SAVE TRANSACTION A1;

    DECLARE @capacidade INT;
    DECLARE @lugares_reservados INT;

    SELECT @capacidade = capacidade, @lugares_reservados = lugares_reservados 
    FROM voos 
    WHERE id = @voo_id;

    IF @lugares_reservados + @lugares_a_reservar > @capacidade
    BEGIN
        RAISERROR('Não há lugares suficientes disponíveis para reservar!', 16, 1);
        ROLLBACK; -- Reverte a transação em caso de erro
    END

    -- Aqui, vamos forçar um erro ao tentar atualizar com um valor inválido
    UPDATE voos
    SET lugares_reservados = NULL -- Forçando um erro, pois NULL não é um valor válido para reservas
    WHERE id = @voo_id;

    COMMIT; -- Confirma a transação se tudo estiver correto
    PRINT 'Transação bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    -- Se ocorrer um erro, reverte para o SAVEPOINT A1
    IF XACT_STATE() <> 0 -- Verifica os status da Transação 0 para inativa e 1 para ativa
    BEGIN
        ROLLBACK TRANSACTION A1; -- Retorna ao SAVEPOINT A1
        PRINT 'Retornando ao SAVEPOINT A1.';
    END
    PRINT 'Transação abortada: ' + ERROR_MESSAGE(); -- Imprime a mensagem de erro
END CATCH;

select * from voos
delete from voos
where id = 2;
-- Simulando uma falha do sistema
BEGIN TRY
    DECLARE @voo_id INT = 2;
    DECLARE @lugares_a_reservar INT = 1;

    PRINT 'Iniciando transação com falha do sistema...';
    BEGIN TRANSACTION;

    -- Simulando uma falha do sistema
    IF @voo_id = 2 AND @lugares_a_reservar = 1
    BEGIN
        RAISERROR('Falha do sistema ao tentar reservar!', 16, 1);
        ROLLBACK 
    END

    -- Atualiza o número de lugares reservados
    UPDATE voos
    SET lugares_reservados = lugares_reservados + @lugares_a_reservar
    WHERE id = @voo_id;

    COMMIT;
    PRINT 'Transação bem-sucedida! Reservas atualizadas.';
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transação abortada: ' + ERROR_MESSAGE();
END CATCH;

-- Verificando consistência após falha do sistema
PRINT 'Verificando consistência após falha do sistema:';
EXEC VerificarConsistencia;