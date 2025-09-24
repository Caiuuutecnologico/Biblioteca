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
	telefone VARCHAR(15),
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
    INSERT INTO livro (titulo, autor, quantidade)
    VALUES (@titulo, @autor, @quantidade);
END;
GO

--READ
CREATE PROCEDURE sp_livro_select
AS
BEGIN
    SELECT id, titulo, autor, quantidade
    FROM livro;
END;
GO

--UPDATE
CREATE PROCEDURE sp_livro_update
    @id INT,
    @titulo VARCHAR(100),
    @autor VARCHAR(100),
    @quantidade INT
AS
BEGIN
    UPDATE livro
    SET titulo = @titulo,
        autor = @autor,
        quantidade = @quantidade
    WHERE id = @id;
END;
GO

--DELETE
CREATE PROCEDURE sp_livro_delete
    @id INT
AS
BEGIN
    DELETE FROM livro
    WHERE id = @id;
END;
GO

--Procedures pra pessoa
--CREATE
CREATE PROCEDURE sp_pessoa_insert
    @nome VARCHAR(100),
    @telefone VARCHAR(15),
	@email VARCHAR(50)
AS
BEGIN
    INSERT INTO pessoa(nome, telefone, email) VALUES
    (@nome, @telefone, @email)
END
GO

--READ
CREATE PROCEDURE sp_pessoa_select
AS
BEGIN
    SELECT id, nome, telefone, email
    FROM pessoa
END
GO

--UPDATE
CREATE PROCEDURE sp_pessoa_update
    @id INT,
    @nome VARCHAR(100),
    @telefone VARCHAR(15),
	@email VARCHAR(50)
AS
BEGIN
    UPDATE pessoa
    SET nome = @nome,
        telefone = @telefone,
        email = @email
    WHERE
        id = @id
END
GO

--DELETE
CREATE PROCEDURE sp_pessoa_delete
    @id int
AS
BEGIN
    DELETE FROM pessoa
    WHERE id = @id
END
GO

--Procedures pra emprestimo
--CREATE
CREATE PROCEDURE sp_emprestimo_insert
    @id_livro INT,
    @id_pessoa INT,
    @status_emprestimo VARCHAR(100) = 'ativo'
AS
BEGIN
    INSERT INTO emprestimo (id_livro, id_pessoa, status_emprestimo)
    VALUES (@id_livro, @id_pessoa, @status_emprestimo);
END;
GO

--READ
CREATE PROCEDURE sp_emprestimo_read
AS
BEGIN
    SELECT id_livro, id_pessoa, status_emprestimo FROM emprestimo;
END;
GO

--UPDATE
CREATE PROCEDURE sp_update_emprestimo
    @id INT,
    @id_livro INT = NULL,
    @id_pessoa INT = NULL,
    @status_emprestimo VARCHAR(100) = NULL
AS
BEGIN
    UPDATE emprestimo
    SET
        id_livro = COALESCE(@id_livro, id_livro),
        id_pessoa = COALESCE(@id_pessoa, id_pessoa),
        status_emprestimo = COALESCE(@status_emprestimo, status_emprestimo)
    WHERE id = @id;
END;
GO

--DELETE
CREATE PROCEDURE sp_emprestimo_delete
    @id INT
AS
BEGIN
    DELETE FROM emprestimo
    WHERE id = @id;
END;
