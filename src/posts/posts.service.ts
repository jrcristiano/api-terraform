import { Injectable, NotFoundException } from '@nestjs/common';
import { Post } from './interfaces/post.interface';

@Injectable()
export class PostsService {
  private readonly posts: Post[] = [
    {
      id: 1,
      title: 'Introdução ao NestJS',
      body: 'NestJS é um framework para construção de aplicações Node.js escaláveis.',
      author: 'Cristiano',
      createdAt: '2026-07-30T20:00:00.000Z',
    },
    {
      id: 2,
      title: 'Estrutura de módulos',
      body: 'Módulos ajudam a organizar o código em unidades coesas.',
      author: 'Ana',
      createdAt: '2026-07-28T14:30:00.000Z',
    },
    {
      id: 3,
      title: 'Controllers e services',
      body: 'Controllers recebem as requisições enquanto services contêm a lógica de negócio.',
      author: 'Lucas',
      createdAt: '2026-07-29T12:15:00.000Z',
    },
    {
      id: 4,
      title: 'Injeção de dependências',
      body: 'O NestJS usa injeção de dependência para gerenciar objetos e facilitar testes.',
      author: 'Mariana',
      createdAt: '2026-07-25T09:00:00.000Z',
    },
    {
      id: 5,
      title: 'Testes com Jest',
      body: 'Jest é uma ferramenta popular para testes unitários em projetos TypeScript.',
      author: 'Pedro',
      createdAt: '2026-07-26T18:45:00.000Z',
    },
  ];

  getAll(): { data: Post[]; total: number } {
    return {
      data: this.posts,
      total: this.posts.length,
    };
  }

  getById(id: number): { data: Post } {
    const post = this.posts.find((item) => item.id === id);

    if (!post) {
      throw new NotFoundException(`Post with id ${id} not found`);
    }

    return { data: post };
  }
}
