import { Test, TestingModule } from '@nestjs/testing';
import { PostsController } from './posts.controller';
import { PostsService } from './posts.service';

const mockPostsService = {
  getAll: jest.fn().mockReturnValue({ data: [], total: 0 }),
  getById: jest.fn().mockReturnValue({ data: { id: 1, title: 'test', body: 'test', author: 'test', createdAt: '2026-07-30T20:00:00.000Z' } }),
};

describe('PostsController', () => {
  let controller: PostsController;
  let service: PostsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PostsController],
      providers: [
        {
          provide: PostsService,
          useValue: mockPostsService,
        },
      ],
    }).compile();

    controller = module.get<PostsController>(PostsController);
    service = module.get<PostsService>(PostsService);
  });

  it('should delegate getAll to service', () => {
    const result = controller.getAll();

    expect(service.getAll).toHaveBeenCalled();
    expect(result).toEqual({ data: [], total: 0 });
  });

  it('should delegate getById to service', () => {
    const result = controller.getById(1);

    expect(service.getById).toHaveBeenCalledWith(1);
    expect(result).toEqual({
      data: {
        id: 1,
        title: 'test',
        body: 'test',
        author: 'test',
        createdAt: '2026-07-30T20:00:00.000Z',
      },
    });
  });
});
