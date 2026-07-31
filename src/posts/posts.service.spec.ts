import { NotFoundException } from '@nestjs/common';
import { PostsService } from './posts.service';

describe('PostsService', () => {
  let service: PostsService;

  beforeEach(() => {
    service = new PostsService();
  });

  it('should return all posts', () => {
    const result = service.getAll();

    expect(result.data).toHaveLength(5);
    expect(result.total).toBe(5);
  });

  it('should return a post by id', () => {
    const result = service.getById(1);

    expect(result.data).toBeDefined();
    expect(result.data.id).toBe(1);
    expect(result.data.title).toBe('Introdução ao NestJS');
  });

  it('should throw NotFoundException for missing post', () => {
    expect(() => service.getById(999)).toThrow(NotFoundException);
  });
});
