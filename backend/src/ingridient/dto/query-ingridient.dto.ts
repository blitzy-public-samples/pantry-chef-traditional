import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { Ingridient } from '../domain/ingrident';

export class FilterIngridientDto {
  @IsOptional()
  query?: string | null;
}

export class SortIngridientDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof Ingridient;

  @ApiProperty()
  @IsString()
  order: string;
}

export class QueryIngridientDto {
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 1))
  @IsNumber()
  @IsOptional()
  page: number;

  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 10))
  @IsNumber()
  @IsOptional()
  limit: number;

  @ApiProperty()
  @IsString()
  @IsOptional()
  query?: string;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) =>
    value ? plainToInstance(FilterIngridientDto, JSON.parse(value)) : undefined,
  )
  @ValidateNested()
  @Type(() => FilterIngridientDto)
  filters?: FilterIngridientDto | null;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) => {
    return value
      ? plainToInstance(SortIngridientDto, JSON.parse(value))
      : undefined;
  })
  @ValidateNested({ each: true })
  @Type(() => SortIngridientDto)
  sort?: SortIngridientDto[] | null;
}
