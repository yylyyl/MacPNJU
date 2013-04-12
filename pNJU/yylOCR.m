#import "yylOCR.h"
#import "n.h"
@implementation yylOCR

- (id)initWithFile:(NSString *)file_name
{
    self = [self init];
    
    //turn png into bmp so that i can process
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file_name];
    bmp = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    
    return self;
}

- (id)initWithData:(NSData *)data
{
    self = [self init];
    NSImage *image = [[NSImage alloc] initWithData:data];
    bmp = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    return self;
}

- (NSString *)getCode
{
    // 1 => 4
    if ([bmp pixelsWide] != 80 || [bmp pixelsHigh] != 25)
    {
        // ?!
        return @"0";
    }

    
    // 14 x 25
    int n1[25][14], n2[25][14], n3[25][14], n4[25][14];

    for (int y = 0; y < 25; y++)
    {
        for (int x = 0; x < 80; x++)
        {
            NSColor *color = [bmp colorAtX:x y:y];
            float r = [color redComponent];
            float g = [color greenComponent];
            float b = [color blueComponent];
            
            short c = (r < 0.4 || g < 0.4 || b < 0.4)?1:2;
            
            if (x >= 11 && x <= 25)
                n1[y][x-11] = c;
            if (x >= 27 && x <= 41)
                n2[y][x-27] = c;
            if (x >= 44 && x <= 58)
                n3[y][x-44] = c;
            if (x >= 61 && x <= 75)
                n4[y][x-60] = c;
            
        }
    }
    
    int num1 = [self arrayToNumber:n1];
    int num2 = [self arrayToNumber:n2];
    int num3 = [self arrayToNumber:n3];
    int num4 = [self arrayToNumber:n4];
    //printf("6 %d", num);
    
    NSString *code = [NSString stringWithFormat:@"%d%d%d%d", num1, num2, num3, num4];
    return code;
}

- (int)arrayToNumber:(int[25][14])a
{
    int *b = [self adjust:a];
    for (int j = 0; j < 25; j++)
    {
        for (int i = 0; i < 14; i++)
        {
            a[j][i] = b[j*14 + i];
        }
    }
    free(b);
    
    
    int p[10]; // 1 matched
    int c[10]; // 1 in pattern
    float percentage[10];
    for (int k = 0; k < 10; k++)
    {
        p[k] = 0;
        c[k] = 0;
        //printf("%d:\n",k);
        for (int j = 0; j < 25; j++)
        {
            for (int i = 0; i < 14; i++)
            {
                if (n[k][j][i]==1)
                {
                    c[k]++;
                }
                if(n[k][j][i] == a[j][i])
                {
                    p[k]++;
                    //printf("1, ");
                }
                //else
                    //printf("0, ");
            }
            //printf("\n");
        }
        //NSLog(@"%d  %d", k, p[k]);
        //printf("\n");
        percentage[k] = (float) p[k] / c[k];
        if (percentage[k]==1)
        {
            return k;
        }
    }
    
    
    float max = 0;
    int result = 0;
    for (int k = 0; k < 10; k++)
    {
        if (percentage[k] > max)
        {
            max = percentage[k];
            result = k;
        }
    }

    return result;
}

-(int *)adjust:(int[25][14])a
{
    int *m = malloc(sizeof(int)*25*14);
    
    int first_line = 0;
    for (int k = 0; k < 25; k++)
    {
        int c = 0;
        for (int j = 0; j < 14; j++)
        {
            if (a[k][j]==1)
            {
                c++;
            }
        }
        if (c > 1)
        {
            first_line = k;
            break;
        }
    }
    
    for (int k = 0; k < 25; k++)
    {
        for (int j = 0; j < 14; j++)
        {
            if (k + first_line < 25)
            {
                m[k*14 + j] = a[k + first_line][j];
            }
            else
            {
                m[k*14 + j] = 2;
            }
        }
    }
    
    return m;
}
@end
