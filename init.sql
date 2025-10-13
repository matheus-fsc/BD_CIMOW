SET FOREIGN_KEY_CHECKS=0;


-- =========== 1. CRIAÇÃO DAS TABELAS (ESTRUTURA) ===========

-- Tabela Central de Usuários
CREATE TABLE IF NOT EXISTS `Usuarios` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(255) NOT NULL,
    `cpf` VARCHAR(14) NOT NULL UNIQUE,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `senha` VARCHAR(255) NOT NULL, -- Lembre-se de armazenar a senha com hash!
    `data_nascimento` DATE NOT NULL,
    `telefone` VARCHAR(20),
    `tipo_usuario` ENUM('paciente', 'medico', 'admin') NOT NULL,
    `status` ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabela de Médicos
CREATE TABLE IF NOT EXISTS `Medicos` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT NOT NULL UNIQUE,
    `crm` VARCHAR(20) NOT NULL UNIQUE,
    `especialidade` VARCHAR(100) NOT NULL,
    FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabela de Pacientes
CREATE TABLE IF NOT EXISTS `Pacientes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT NOT NULL UNIQUE,
    `historico_medico` TEXT,
    FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabela de Consultas
CREATE TABLE IF NOT EXISTS `Consultas` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `paciente_id` INT NOT NULL,
    `medico_id` INT NOT NULL,
    `data_hora` DATETIME NOT NULL,
    `status` ENUM('agendada', 'realizada', 'cancelada') NOT NULL DEFAULT 'agendada',
    `tipo_consulta` ENUM('online', 'presencial') NOT NULL,
    `link_atendimento` VARCHAR(255),
    `observacoes` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`paciente_id`) REFERENCES `Pacientes`(`id`),
    FOREIGN KEY (`medico_id`) REFERENCES `Medicos`(`id`)
) ENGINE=InnoDB;

-- Tabela de Prontuários
CREATE TABLE IF NOT EXISTS `Prontuarios` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `consulta_id` INT NOT NULL UNIQUE,
    `paciente_id` INT NOT NULL,
    `medico_id` INT NOT NULL,
    `anotacoes_medicas` TEXT NOT NULL,
    `diagnostico` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`consulta_id`) REFERENCES `Consultas`(`id`),
    FOREIGN KEY (`paciente_id`) REFERENCES `Pacientes`(`id`),
    FOREIGN KEY (`medico_id`) REFERENCES `Medicos`(`id`)
) ENGINE=InnoDB;

-- Tabela de Prescrições
CREATE TABLE IF NOT EXISTS `Prescricoes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `prontuario_id` INT NOT NULL,
    `medicamento` VARCHAR(255) NOT NULL,
    `dosagem` VARCHAR(100) NOT NULL,
    `frequencia` VARCHAR(100) NOT NULL,
    `duracao_tratamento` VARCHAR(100),
    `instrucoes_adicionais` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`prontuario_id`) REFERENCES `Prontuarios`(`id`)
) ENGINE=InnoDB;

-- Tabela de Logs de Atividades
CREATE TABLE IF NOT EXISTS `LogsAtividades` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT,
    `acao` VARCHAR(255) NOT NULL,
    `descricao` TEXT,
    `data_hora` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;


-- =========== 2. CRIAÇÃO DE ÍNDICES (PERFORMANCE) ===========

-- Índices na tabela de Consultas
CREATE INDEX idx_consultas_paciente_id ON Consultas(paciente_id);
CREATE INDEX idx_consultas_medico_id ON Consultas(medico_id);
CREATE INDEX idx_consultas_data_hora ON Consultas(data_hora);

-- Índices na tabela de Prontuários
CREATE INDEX idx_prontuarios_paciente_id ON Prontuarios(paciente_id);
CREATE INDEX idx_prontuarios_medico_id ON Prontuarios(medico_id);

-- Índice na tabela de Prescrições
CREATE INDEX idx_prescricoes_prontuario_id ON Prescricoes(prontuario_id);

-- Índice na tabela de Logs de Atividades
CREATE INDEX idx_logsatividades_usuario_id ON LogsAtividades(usuario_id);


-- Reabilita a verificação de chaves estrangeiras
SET FOREIGN_KEY_CHECKS=1;
