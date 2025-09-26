--Drop das Tabelas
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS pessoa;
DROP TABLE IF EXISTS livro;

--Criação das Tabelas

CREATE TABLE livro (   
	id INT IDENTITY(1,1) PRIMARY KEY,
	titulo VARCHAR(100),
	autor VARCHAR(100),
	quantidade int
);

CREATE TABLE pessoa (
	id INT IDENTITY(1,1) PRIMARY KEY,
	nome VARCHAR(100),
	telefone VARCHAR(11),
	email VARCHAR(50)
);

CREATE TABLE emprestimo (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_livro INT,
	id_pessoa INT,
	status_emprestimo VARCHAR(100) DEFAULT 'ativo',
	FOREIGN KEY (id_livro) REFERENCES livro(id),
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id)
);
GO

--Criação das Procedures

--Procedures pra livro
--CREATE
CREATE PROCEDURE sp_livro_insert
    @titulo VARCHAR(100),
    @autor VARCHAR(100),
    @quantidade INT
AS
BEGIN
BEGIN TRY
  IF (@titulo IS NULL OR LTRIM(RTRIM(@titulo)) = '')

  BEGIN
     RAISERROR('O título do livro é obrigatório.', 16, 1);
     RETURN;
  END

  IF (@autor IS NULL OR LTRIM(RTRIM(@autor)) = '')

  BEGIN
     RAISERROR('O autor do livro é obrigatório.', 16, 1);
     RETURN;
  END

  IF (@quantidade IS NULL OR @quantidade < 0)

  BEGIN
     RAISERROR('A quantidade de livros é obrigatório.', 16, 1);
     RETURN;
  END

  IF EXISTS (
    SELECT 1 FROM livro 
    WHERE titulo = @titulo AND autor = @autor
)
    BEGIN
            RAISERROR('Já existe um livro cadastrado com este título e autor.', 16, 1);
            RETURN;
    END

    INSERT INTO livro (titulo, autor, quantidade)
    VALUES (@titulo, @autor, @quantidade);

    PRINT 'Livro cadastrado com sucesso.';

END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao inserir livro: %s', 16, 1, @ErroMsg);
END CATCH
END
GO

--READ
CREATE PROCEDURE sp_livro_select
@id INT = NULL
AS
BEGIN
BEGIN TRY
    IF (@id IS NULL)
        SELECT * FROM livro;
    ELSE
        SELECT * FROM livro WHERE id = @id;
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao selecionar livro: %s', 16, 1, @ErroMsg);
END CATCH
END
GO

--UPDATE
CREATE PROCEDURE sp_livro_update
    @id INT,
    @titulo VARCHAR(100),
    @autor VARCHAR(100),
    @quantidade INT
AS
BEGIN
BEGIN TRY

    IF (@id IS NULL)
    BEGIN
        RAISERROR('O id do livro é obrigatório.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT id FROM livro WHERE id = @id)
    BEGIN
         RAISERROR('Não existe esse id.', 16, 1);
         RETURN;
    END

    IF (@titulo IS NULL OR LTRIM(RTRIM(@titulo)) = '')
    BEGIN
        RAISERROR('O título do livro é obrigatório.', 16, 1);
        RETURN;
    END

    IF (@autor IS NULL OR LTRIM(RTRIM(@autor)) = '')

    BEGIN
        RAISERROR('O autor do livro é obrigatório.', 16, 1);
        RETURN;
    END

    IF (@quantidade IS NULL OR @quantidade < 0)

    BEGIN
         RAISERROR('A quantidade de livros é obrigatório.', 16, 1);
        RETURN;
    END

    IF EXISTS (
    SELECT 1 FROM livro
    WHERE titulo = @titulo AND autor = @autor AND id <> @id
    )
    BEGIN
        RAISERROR('Já existe outro livro com este título e autor.', 16, 1);
        RETURN;
    END

    UPDATE livro
    SET titulo = @titulo,
        autor = @autor,
        quantidade = @quantidade
    WHERE id = @id;

    PRINT 'Livro atualizado com sucesso.';

END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao atualizar livro: %s', 16, 1, @ErroMsg);
END CATCH
END;
GO

--DELETE
CREATE PROCEDURE sp_livro_delete
    @id INT
AS
BEGIN
BEGIN TRY

    IF (@id IS NULL)
    BEGIN
        RAISERROR('O id do livro é obrigatório.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT id FROM livro WHERE id = @id)
    BEGIN
         RAISERROR('Não existe esse id.', 16, 1);
         RETURN;
    END

    IF EXISTS (SELECT 1 FROM emprestimo WHERE id_livro = @id)
    BEGIN
        RAISERROR('Não é possível deletar este livro, pois existem empréstimos vinculados.', 16, 1);
        RETURN;
    END


    DELETE FROM livro
    WHERE id = @id;

    PRINT 'Livro deletado.';

END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao deletar livro: %s', 16, 1, @ErroMsg);
END CATCH
END;
GO

--Procedures pra pessoa
--CREATE
CREATE PROCEDURE sp_pessoa_insert
    @nome VARCHAR(100),
    @telefone VARCHAR(11),
	@email VARCHAR(50)
AS
BEGIN
BEGIN TRY

    IF (@nome IS NULL OR LTRIM(RTRIM(@nome)) = '')
    BEGIN
        RAISERROR('O nome da pessoa é obrigatório.', 16, 1);
        RETURN;
    END

    IF (@telefone IS NULL OR LTRIM(RTRIM(@telefone)) = '')

    BEGIN
        RAISERROR('O telefone é obrigatório.', 16, 1);
        RETURN;
    END

    IF (@email IS NULL OR LTRIM(RTRIM(@email)) = '')
    
    BEGIN
        RAISERROR('O email é obrigatório.', 16, 1);
        RETURN;
    END

    IF PATINDEX('%_@_%._%', @email) = 0
    BEGIN
        RAISERROR('O email é inválido.', 16, 1);
        RETURN;
    END

    INSERT INTO pessoa(nome, telefone, email) VALUES
    (@nome, @telefone, @email)

    PRINT 'Pessoa cadastrada com sucesso.';

END TRY
BEGIN CATCH 
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao criar pessoa: %s', 16, 1, @ErroMsg);
END CATCH
END
GO

--READ
CREATE PROCEDURE sp_pessoa_select
@id INT = NULL
AS
BEGIN
BEGIN TRY

    IF (@id IS NULL)
        SELECT * FROM pessoa;
    ELSE
        SELECT * FROM pessoa WHERE id = @id;
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao selecionar pessoa: %s', 16, 1, @ErroMsg);
END CATCH
END
GO

--UPDATE
CREATE PROCEDURE sp_pessoa_update
    @id INT,
    @nome VARCHAR(100),
    @telefone VARCHAR(11),
	@email VARCHAR(50)
AS
BEGIN
BEGIN TRY

    IF (@ID IS NULL)
    BEGIN
        RAISERROR('O id da pessoa é obrigatório.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT id FROM pessoa WHERE id = @id)
    BEGIN
         RAISERROR('Não existe esse id.', 16, 1);
         RETURN;
    END

    IF (@nome IS NULL OR LTRIM(RTRIM(@nome)) = '')
    BEGIN
        RAISERROR('O nome da pessoa é obrigatório.', 16, 1);
        RETURN;
    END

    IF (@telefone IS NULL OR LTRIM(RTRIM(@telefone)) = '')

    BEGIN
        RAISERROR('O telefone é obrigatório.', 16, 1);
        RETURN;
    END

    IF (@email IS NULL OR LTRIM(RTRIM(@email)) = '')
    
    BEGIN
        RAISERROR('O email é obrigatório.', 16, 1);
        RETURN;
    END

    IF PATINDEX('%_@_%._%', @email) = 0
    BEGIN
        RAISERROR('O email é inválido.', 16, 1);
        RETURN;
    END

    UPDATE pessoa
    SET nome = @nome,
        telefone = @telefone,
        email = @email
    WHERE
        id = @id

    PRINT 'Pessoa atualizada com sucesso.';
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao atualizar pessoa: %s', 16, 1, @ErroMsg);
END CATCH
END
GO

--DELETE
CREATE PROCEDURE sp_pessoa_delete
    @id int
AS
BEGIN
BEGIN TRY

    IF (@ID IS NULL)
    BEGIN
        RAISERROR('O id da pessoa é obrigatório.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT id FROM pessoa WHERE id = @id)
    BEGIN
         RAISERROR('Não existe esse id.', 16, 1);
         RETURN;
    END

    IF EXISTS (SELECT 1 FROM emprestimo WHERE id_pessoa = @id)
    BEGIN
        RAISERROR('Não é possível deletar esta pessoa, pois existem empréstimos vinculados.', 16, 1);
        RETURN;
    END

    DELETE FROM pessoa
    WHERE id = @id

    PRINT 'Pessoa deletada.';

END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao deletar pessoa: %s', 16, 1, @ErroMsg);
END CATCH
END
GO

--Procedures pra emprestimo
-- CREATE
CREATE PROCEDURE sp_emprestimo_insert
    @id_livro INT,
    @id_pessoa INT,
    @status_emprestimo VARCHAR(100) = 'ativo'
AS
BEGIN
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM livro WHERE id = @id_livro)
    BEGIN
        RAISERROR('O livro informado não existe.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM pessoa WHERE id = @id_pessoa)
    BEGIN
        RAISERROR('A pessoa informada não existe.', 16, 1);
        RETURN;
    END

    IF (@status_emprestimo NOT IN ('ativo', 'inativo'))
    BEGIN
        RAISERROR('O status do empréstimo deve ser "ativo" ou "inativo".', 16, 1);
        RETURN;
    END

    DECLARE @quantidade INT;
    DECLARE @emprestimos_ativos INT;

    SELECT @quantidade = quantidade FROM livro WHERE id = @id_livro;

    SELECT @emprestimos_ativos = COUNT(*)
    FROM emprestimo
    WHERE id_livro = @id_livro AND status_emprestimo = 'ativo';

    IF @emprestimos_ativos >= @quantidade
    BEGIN
        RAISERROR('Não é possível realizar o empréstimo. Quantidade máxima atingida para este livro.', 16, 1);
        RETURN;
    END

    INSERT INTO emprestimo (id_livro, id_pessoa, status_emprestimo)
    VALUES (@id_livro, @id_pessoa, @status_emprestimo);

    PRINT 'Empréstimo criado com sucesso.';
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao criar empréstimo: %s', 16, 1, @ErroMsg);
END CATCH
END;
GO

-- READ
CREATE PROCEDURE sp_emprestimo_select
    @id INT = NULL
AS
BEGIN
BEGIN TRY
    IF (@id IS NULL)
        SELECT * FROM emprestimo;
    ELSE
        SELECT * FROM emprestimo WHERE id = @id;
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao selecionar empréstimo: %s', 16, 1, @ErroMsg);
END CATCH
END;
GO

--READ EMPRESTIMO POR LIVRO E PESSOA
CREATE PROCEDURE sp_emprestimo_prettier_select
    @id INT = NULL
AS
BEGIN
    BEGIN TRY
        IF (@id IS NULL)
        BEGIN
            SELECT 
                e.id AS emprestimo_id, 
                e.status_emprestimo, 
                l.titulo, 
                p.nome
            FROM emprestimo AS e
            INNER JOIN livro AS l ON l.id = e.id_livro
            INNER JOIN pessoa AS p ON p.id = e.id_pessoa
            ORDER BY e.id ASC;
        END
        ELSE
        BEGIN
            SELECT 
                e.id AS emprestimo_id, 
                e.status_emprestimo, 
                l.titulo, 
                p.nome
            FROM emprestimo AS e
            INNER JOIN livro AS l ON l.id = e.id_livro
            INNER JOIN pessoa AS p ON p.id = e.id_pessoa
            WHERE e.id = @id
            ORDER BY e.id ASC;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro ao selecionar empréstimo: %s', 16, 1, @ErroMsg);
    END CATCH
END
GO
    


-- UPDATE
CREATE PROCEDURE sp_emprestimo_update
    @id INT,
    @id_livro INT = NULL,
    @id_pessoa INT = NULL,
    @status_emprestimo VARCHAR(100) = NULL
AS
BEGIN
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM emprestimo WHERE id = @id)
    BEGIN
        RAISERROR('O empréstimo informado não existe.', 16, 1);
        RETURN;
    END

    IF (@status_emprestimo IS NOT NULL AND @status_emprestimo NOT IN ('ativo', 'inativo'))
    BEGIN
        RAISERROR('O status do empréstimo deve ser "ativo" ou "inativo".', 16, 1);
        RETURN;
    END

    IF (@id_livro IS NOT NULL AND NOT EXISTS (SELECT 1 FROM livro WHERE id = @id_livro))
    BEGIN
        RAISERROR('O livro informado não existe.', 16, 1);
        RETURN;
    END

    IF (@id_pessoa IS NOT NULL AND NOT EXISTS (SELECT 1 FROM pessoa WHERE id = @id_pessoa))
    BEGIN
        RAISERROR('A pessoa informada não existe.', 16, 1);
        RETURN;
    END

    IF (@status_emprestimo = 'ativo' OR @id_livro IS NOT NULL)
    BEGIN
        DECLARE @livroAtual INT;
        DECLARE @quantidade INT;
        DECLARE @emprestimos_ativos INT;

        SELECT @livroAtual = COALESCE(@id_livro, id_livro) 
        FROM emprestimo WHERE id = @id;

        SELECT @quantidade = quantidade FROM livro WHERE id = @livroAtual;

        SELECT @emprestimos_ativos = COUNT(*)
        FROM emprestimo
        WHERE id_livro = @livroAtual 
          AND status_emprestimo = 'ativo'
          AND id <> @id; -- exclui o próprio registro

        IF @emprestimos_ativos >= @quantidade
        BEGIN
            RAISERROR('Não é possível ativar o empréstimo. Quantidade máxima atingida para este livro.', 16, 1);
            RETURN;
        END
    END

    UPDATE emprestimo
    SET
        id_livro = COALESCE(@id_livro, id_livro),
        id_pessoa = COALESCE(@id_pessoa, id_pessoa),
        status_emprestimo = COALESCE(@status_emprestimo, status_emprestimo)
    WHERE id = @id;

    PRINT 'Empréstimo atualizado com sucesso.';
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao atualizar empréstimo: %s', 16, 1, @ErroMsg);
END CATCH
END;
GO

-- DELETE
CREATE PROCEDURE sp_emprestimo_delete
    @id INT
AS
BEGIN
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM emprestimo WHERE id = @id)
    BEGIN
        RAISERROR('O empréstimo informado não existe.', 16, 1);
        RETURN;
    END

    DELETE FROM emprestimo
    WHERE id = @id;

    PRINT 'Empréstimo deletado.';
END TRY
BEGIN CATCH
    DECLARE @ErroMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro ao deletar empréstimo: %s', 16, 1, @ErroMsg);
END CATCH
END;
GO
